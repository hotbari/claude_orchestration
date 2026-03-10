/**
 * State Manager Utility for Web Autopilot
 * Manages state file operations, validation, and phase transitions
 */

const fs = require('fs');
const path = require('path');

const STATE_FILE_PATH = path.join(process.cwd(), '.omc', 'state', 'web-autopilot-state.json');

/**
 * Phase dependency map - defines which phase must complete before another can start
 */
const PHASE_DEPENDENCIES = {
  "requirements": "design-analysis",
  "architecture": "requirements",
  "implementation": "architecture",
  "qa": "implementation",
  "completion": "qa"
};

/**
 * Valid phase names
 */
const VALID_PHASES = [
  "design-analysis",
  "requirements",
  "architecture",
  "implementation",
  "qa",
  "completion"
];

/**
 * Valid phase statuses
 */
const VALID_STATUSES = ["pending", "in_progress", "completed", "failed"];

/**
 * Valid review results
 */
const VALID_REVIEW_RESULTS = ["pending", "approved", "rejected"];

/**
 * Reads and parses the state file
 *
 * @returns {Object|null} Parsed state object or null if file doesn't exist
 * @throws {Error} If state file exists but is invalid JSON
 */
function readState() {
  try {
    if (!fs.existsSync(STATE_FILE_PATH)) {
      return null;
    }

    const content = fs.readFileSync(STATE_FILE_PATH, 'utf8');
    const state = JSON.parse(content);

    // Validate state structure
    validateState(state);

    return state;
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error(`Invalid JSON in state file: ${error.message}`);
    }
    throw error;
  }
}

/**
 * Writes state to file with validation
 *
 * @param {Object} state - State object to write
 * @throws {Error} If state object is invalid
 */
function writeState(state) {
  // Validate before writing
  validateState(state);

  // Ensure directory exists
  const stateDir = path.dirname(STATE_FILE_PATH);
  if (!fs.existsSync(stateDir)) {
    fs.mkdirSync(stateDir, { recursive: true });
  }

  // Write with pretty formatting
  fs.writeFileSync(STATE_FILE_PATH, JSON.stringify(state, null, 2), 'utf8');
}

/**
 * Initializes a new state object
 *
 * @param {string} serviceName - Name of the service being built
 * @param {string} figmaUrl - Figma design URL
 * @returns {Object} Initialized state object
 * @throws {Error} If parameters are invalid
 */
function initState(serviceName, figmaUrl) {
  if (!serviceName || typeof serviceName !== 'string') {
    throw new Error('serviceName must be a non-empty string');
  }

  if (!figmaUrl || typeof figmaUrl !== 'string') {
    throw new Error('figmaUrl must be a non-empty string');
  }

  const state = {
    active: true,
    serviceName: serviceName,
    currentPhase: "design-analysis",
    phases: {
      "design-analysis": "pending",
      "requirements": "pending",
      "architecture": "pending",
      "implementation": "pending",
      "qa": "pending",
      "completion": "pending"
    },
    ralphLoop: {
      iterationCount: 0,
      maxIterations: 5,
      lastReviewResult: "pending"
    },
    documents: {},
    figmaUrl: figmaUrl,
    techStack: null
  };

  writeState(state);
  return state;
}

/**
 * Checks if a phase's dependency has been completed
 *
 * @param {string} phase - Phase to check dependency for
 * @returns {boolean} True if dependency is satisfied (or no dependency exists)
 * @throws {Error} If phase is invalid or dependency not met
 */
function checkDependency(phase) {
  if (!VALID_PHASES.includes(phase)) {
    throw new Error(`Invalid phase: ${phase}. Must be one of: ${VALID_PHASES.join(', ')}`);
  }

  // First phase has no dependency
  if (phase === "design-analysis") {
    return true;
  }

  const state = readState();
  if (!state) {
    throw new Error('No active state found. Initialize state first.');
  }

  const requiredPhase = PHASE_DEPENDENCIES[phase];
  if (!requiredPhase) {
    return true; // No dependency
  }

  const dependencyStatus = state.phases[requiredPhase];
  if (dependencyStatus !== "completed") {
    throw new Error(
      `Cannot start phase "${phase}". Dependency "${requiredPhase}" is ${dependencyStatus}, must be completed.`
    );
  }

  return true;
}

/**
 * Updates a phase's status
 *
 * @param {string} phase - Phase to update
 * @param {string} status - New status (pending|in_progress|completed|failed)
 * @throws {Error} If phase or status is invalid, or dependency not met
 */
function updatePhase(phase, status) {
  if (!VALID_PHASES.includes(phase)) {
    throw new Error(`Invalid phase: ${phase}. Must be one of: ${VALID_PHASES.join(', ')}`);
  }

  if (!VALID_STATUSES.includes(status)) {
    throw new Error(`Invalid status: ${status}. Must be one of: ${VALID_STATUSES.join(', ')}`);
  }

  const state = readState();
  if (!state) {
    throw new Error('No active state found. Initialize state first.');
  }

  // Check dependency if moving to in_progress or completed
  if (status === "in_progress" || status === "completed") {
    checkDependency(phase);
  }

  // Update phase status
  state.phases[phase] = status;

  // Update current phase if moving to in_progress
  if (status === "in_progress") {
    state.currentPhase = phase;
  }

  // If completing a phase, move current to next phase
  if (status === "completed") {
    const nextPhase = getNextPhase(phase);
    if (nextPhase) {
      state.currentPhase = nextPhase;
    }
  }

  writeState(state);
}

/**
 * Gets the next phase after the given phase
 *
 * @param {string} phase - Current phase
 * @returns {string|null} Next phase or null if at end
 */
function getNextPhase(phase) {
  const currentIndex = VALID_PHASES.indexOf(phase);
  if (currentIndex === -1 || currentIndex === VALID_PHASES.length - 1) {
    return null;
  }
  return VALID_PHASES[currentIndex + 1];
}

/**
 * Deletes the state file (cleanup on completion)
 *
 * @throws {Error} If state file cannot be deleted
 */
function cleanupState() {
  if (fs.existsSync(STATE_FILE_PATH)) {
    fs.unlinkSync(STATE_FILE_PATH);
  }
}

/**
 * Validates state object structure and values
 *
 * @param {Object} state - State object to validate
 * @throws {Error} If state is invalid
 */
function validateState(state) {
  if (!state || typeof state !== 'object') {
    throw new Error('State must be an object');
  }

  // Validate required fields
  if (typeof state.active !== 'boolean') {
    throw new Error('state.active must be a boolean');
  }

  if (!state.serviceName || typeof state.serviceName !== 'string') {
    throw new Error('state.serviceName must be a non-empty string');
  }

  if (!VALID_PHASES.includes(state.currentPhase)) {
    throw new Error(`state.currentPhase must be one of: ${VALID_PHASES.join(', ')}`);
  }

  // Validate phases object
  if (!state.phases || typeof state.phases !== 'object') {
    throw new Error('state.phases must be an object');
  }

  for (const phase of VALID_PHASES) {
    if (!VALID_STATUSES.includes(state.phases[phase])) {
      throw new Error(`state.phases.${phase} must be one of: ${VALID_STATUSES.join(', ')}`);
    }
  }

  // Validate ralphLoop
  if (!state.ralphLoop || typeof state.ralphLoop !== 'object') {
    throw new Error('state.ralphLoop must be an object');
  }

  if (typeof state.ralphLoop.iterationCount !== 'number' || state.ralphLoop.iterationCount < 0) {
    throw new Error('state.ralphLoop.iterationCount must be a non-negative number');
  }

  if (state.ralphLoop.iterationCount > state.ralphLoop.maxIterations) {
    throw new Error('state.ralphLoop.iterationCount cannot exceed maxIterations');
  }

  if (typeof state.ralphLoop.maxIterations !== 'number' || state.ralphLoop.maxIterations < 1) {
    throw new Error('state.ralphLoop.maxIterations must be a positive number');
  }

  if (!VALID_REVIEW_RESULTS.includes(state.ralphLoop.lastReviewResult)) {
    throw new Error(`state.ralphLoop.lastReviewResult must be one of: ${VALID_REVIEW_RESULTS.join(', ')}`);
  }

  // Validate documents
  if (!state.documents || typeof state.documents !== 'object') {
    throw new Error('state.documents must be an object');
  }

  // Validate figmaUrl
  if (!state.figmaUrl || typeof state.figmaUrl !== 'string') {
    throw new Error('state.figmaUrl must be a non-empty string');
  }

  // Validate techStack (can be null or string)
  if (state.techStack !== null && typeof state.techStack !== 'string') {
    throw new Error('state.techStack must be null or a string');
  }
}

/**
 * Gets current state or throws if not initialized
 *
 * @returns {Object} Current state
 * @throws {Error} If no active state found
 */
function getState() {
  const state = readState();
  if (!state) {
    throw new Error('No active state found. Initialize state first.');
  }
  return state;
}

/**
 * Checks if web-autopilot is currently active
 *
 * @returns {boolean} True if active state exists
 */
function isActive() {
  const state = readState();
  return state !== null && state.active === true;
}

/**
 * Updates the ralphLoop iteration count
 *
 * @param {number} count - New iteration count
 * @throws {Error} If count is invalid or exceeds max
 */
function updateRalphIteration(count) {
  if (typeof count !== 'number' || count < 0) {
    throw new Error('Iteration count must be a non-negative number');
  }

  const state = getState();

  if (count > state.ralphLoop.maxIterations) {
    throw new Error(`Iteration count ${count} exceeds maximum ${state.ralphLoop.maxIterations}`);
  }

  state.ralphLoop.iterationCount = count;
  writeState(state);
}

/**
 * Updates the last review result
 *
 * @param {string} result - Review result (pending|approved|rejected)
 * @throws {Error} If result is invalid
 */
function updateReviewResult(result) {
  if (!VALID_REVIEW_RESULTS.includes(result)) {
    throw new Error(`Invalid review result: ${result}. Must be one of: ${VALID_REVIEW_RESULTS.join(', ')}`);
  }

  const state = getState();
  state.ralphLoop.lastReviewResult = result;
  writeState(state);
}

/**
 * Updates a document path in state
 *
 * @param {string} docType - Document type key
 * @param {string} filePath - Path to document
 */
function updateDocument(docType, filePath) {
  if (!docType || typeof docType !== 'string') {
    throw new Error('docType must be a non-empty string');
  }

  if (!filePath || typeof filePath !== 'string') {
    throw new Error('filePath must be a non-empty string');
  }

  const state = getState();
  state.documents[docType] = filePath;
  writeState(state);
}

/**
 * Updates the tech stack
 *
 * @param {string} techStack - Tech stack description
 */
function updateTechStack(techStack) {
  if (techStack !== null && typeof techStack !== 'string') {
    throw new Error('techStack must be null or a string');
  }

  const state = getState();
  state.techStack = techStack;
  writeState(state);
}

/**
 * Deactivates the current session
 */
function deactivate() {
  const state = getState();
  state.active = false;
  writeState(state);
}

module.exports = {
  readState,
  writeState,
  initState,
  checkDependency,
  updatePhase,
  cleanupState,
  getState,
  isActive,
  updateRalphIteration,
  updateReviewResult,
  updateDocument,
  updateTechStack,
  deactivate,
  VALID_PHASES,
  VALID_STATUSES,
  VALID_REVIEW_RESULTS,
  PHASE_DEPENDENCIES
};
