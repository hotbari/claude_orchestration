# Figma Fidelity Rules for Frontend Implementation

**Core Principle**: Maintain pixel-perfect alignment with Figma design while adhering to shadcn/ui component standards.

**Mandatory Preservation**:
1. **Visual Accuracy** - Keep Figma's exact layout structure, text content (copy), color values (HEX codes), image placements, icon selections, and spacing measurements unchanged during implementation.
2. **Component Constraint** - Implement ALL UI elements exclusively using shadcn/ui components; if a Figma element lacks a direct shadcn equivalent, compose it from multiple shadcn primitives rather than custom HTML.
3. **Positional Priority** - Prioritize positional accuracy over responsive fluidity in initial build; match x/y coordinates, widths, heights, and alignment from design-analysis.md before optimizing for breakpoints.
