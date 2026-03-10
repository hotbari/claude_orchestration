#!/usr/bin/env bash

# init-nextjs.sh - Initialize Next.js project with TypeScript, Tailwind CSS, and App Router
# Usage: ./init-nextjs.sh <project-name> [target-directory]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error handler
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Info message
info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Validate arguments
if [ $# -lt 1 ]; then
    error_exit "Usage: $0 <project-name> [target-directory]"
fi

PROJECT_NAME="$1"
TARGET_DIR="${2:-.}"

# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    error_exit "Project name must contain only lowercase letters, numbers, and hyphens"
fi

# Create target directory if needed
if [ "$TARGET_DIR" != "." ] && [ ! -d "$TARGET_DIR" ]; then
    info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR" || error_exit "Failed to create target directory"
fi

cd "$TARGET_DIR" || error_exit "Failed to change to target directory"

# Check if project already exists
if [ -d "$PROJECT_NAME" ]; then
    error_exit "Project directory '$PROJECT_NAME' already exists"
fi

# Check for required commands
command -v node >/dev/null 2>&1 || error_exit "Node.js is not installed"
command -v npx >/dev/null 2>&1 || error_exit "npx is not installed"

info "Initializing Next.js project: $PROJECT_NAME"

# Create Next.js project with TypeScript and Tailwind CSS
npx create-next-app@latest "$PROJECT_NAME" \
    --typescript \
    --tailwind \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --use-npm \
    --no-git \
    || error_exit "Failed to create Next.js project"

success "Next.js project created"

cd "$PROJECT_NAME" || error_exit "Failed to enter project directory"

# Install additional base dependencies
info "Installing additional dependencies..."
npm install --save \
    axios \
    zod \
    react-hook-form \
    @hookform/resolvers \
    || error_exit "Failed to install dependencies"

npm install --save-dev \
    @types/node \
    @types/react \
    @types/react-dom \
    || error_exit "Failed to install dev dependencies"

success "Dependencies installed"

# Create additional folder structure
info "Setting up project structure..."

mkdir -p src/{components,lib,hooks,types,utils}
mkdir -p src/components/{ui,forms,layout}
mkdir -p src/lib/{api,validation}

success "Folder structure created"

# Create basic utility files
cat > src/lib/api/client.ts << 'EOF'
import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for adding auth token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for handling errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
EOF

cat > src/types/index.ts << 'EOF'
// Global type definitions
export interface ApiError {
  message: string;
  code?: string;
  details?: Record<string, any>;
}

export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}
EOF

cat > src/lib/validation/schemas.ts << 'EOF'
import { z } from 'zod';

// Example validation schemas
export const emailSchema = z.string().email('Invalid email address');

export const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
  .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
  .regex(/[0-9]/, 'Password must contain at least one number');

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, 'Password is required'),
});

export type LoginFormData = z.infer<typeof loginSchema>;
EOF

cat > src/utils/cn.ts << 'EOF'
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

/**
 * Merge Tailwind CSS classes with conflict resolution
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF

# Install clsx and tailwind-merge for cn utility
npm install --save clsx tailwind-merge || error_exit "Failed to install utility dependencies"

success "Utility files created"

# Create .env.local template
cat > .env.local.example << 'EOF'
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:8000/api

# Add other environment variables here
EOF

# Create .gitignore if not exists
if [ ! -f .gitignore ]; then
    cat > .gitignore << 'EOF'
# Dependencies
node_modules
.pnp
.pnp.js

# Testing
coverage

# Next.js
.next
out
build

# Production
dist

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env.local
.env.development.local
.env.test.local
.env.production.local

# Vercel
.vercel

# TypeScript
*.tsbuildinfo
next-env.d.ts
EOF
fi

success "Configuration files created"

# Create README
cat > README.md << EOF
# $PROJECT_NAME

Next.js project with TypeScript, Tailwind CSS, and App Router.

## Getting Started

1. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

2. Copy \`.env.local.example\` to \`.env.local\` and configure:
   \`\`\`bash
   cp .env.local.example .env.local
   \`\`\`

3. Run the development server:
   \`\`\`bash
   npm run dev
   \`\`\`

4. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Structure

- \`src/app/\` - Next.js App Router pages and layouts
- \`src/components/\` - React components
  - \`ui/\` - Reusable UI components
  - \`forms/\` - Form components
  - \`layout/\` - Layout components
- \`src/lib/\` - Utility libraries
  - \`api/\` - API client configuration
  - \`validation/\` - Zod validation schemas
- \`src/hooks/\` - Custom React hooks
- \`src/types/\` - TypeScript type definitions
- \`src/utils/\` - Utility functions

## Available Scripts

- \`npm run dev\` - Start development server
- \`npm run build\` - Build for production
- \`npm start\` - Start production server
- \`npm run lint\` - Run ESLint

## Dependencies

- **Next.js** - React framework with App Router
- **TypeScript** - Static type checking
- **Tailwind CSS** - Utility-first CSS framework
- **Axios** - HTTP client
- **Zod** - Schema validation
- **React Hook Form** - Form management

Created with init-nextjs.sh
EOF

success "README created"

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Next.js project initialized successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Project: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "Location: ${YELLOW}$(pwd)${NC}"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. cp .env.local.example .env.local"
echo "  3. npm run dev"
echo ""
