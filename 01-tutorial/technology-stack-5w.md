# MineContext Frontend Technology Stack - 5W Analysis

## Table of Contents
- [Core Framework](#core-framework)
- [Build & Development Tools](#build--development-tools)
- [UI & Styling](#ui--styling)
- [State Management & Data](#state-management--data)
- [Code Quality & Tooling](#code-quality--tooling)
- [AI & Backend Integration](#ai--backend-integration)

---

## Core Framework

### Electron (v37)
**What**: A framework for building cross-platform desktop applications using web technologies.

**Who**:
- Developed by GitHub/OpenJS Foundation
- Used by: VS Code, Slack, Discord, Figma

**When**:
- Released: 2013
- v37 (current): 2025
- Updated frequently with Chromium releases

**Where**:
- Main process: Node.js backend (`src/main/`)
- Renderer process: Chromium browser (`src/renderer/`)
- Preload scripts: Bridge between main and renderer

**Why**:
- Build once, deploy to macOS, Windows, Linux
- Full access to Node.js APIs and native system features
- Rich ecosystem with native module support
- Enables desktop features: system tray, menubar, file system access, screenshots

---

### React (v19)
**What**: A JavaScript library for building user interfaces with component-based architecture.

**Who**:
- Created by Meta (Facebook)
- Maintained by Meta and community
- Used by: Facebook, Instagram, Netflix, Airbnb

**When**:
- Released: 2013
- v19 (latest): 2024-2025
- New features: React Compiler, improved hooks, better TypeScript support

**Where**:
- Renderer process only (`src/renderer/src/`)
- Component tree structure
- Virtual DOM in browser context

**Why**:
- Declarative UI programming model
- Component reusability and composition
- Excellent TypeScript support
- Large ecosystem of libraries and tools
- Efficient updates with Virtual DOM
- Strong developer tooling

---

### TypeScript (v5.8)
**What**: A typed superset of JavaScript that compiles to plain JavaScript.

**Who**:
- Developed by Microsoft
- Led by Anders Hejlsberg (creator of C#)
- Used across the industry

**When**:
- Released: 2012
- v5.8 (current): 2025
- Major releases every few months

**Where**:
- All source code (`.ts`, `.tsx` files)
- Separate configs for Node (`tsconfig.node.json`) and Web (`tsconfig.web.json`)
- Compile-time type checking

**Why**:
- Catch errors before runtime
- Better IDE autocomplete and refactoring
- Self-documenting code with type annotations
- Enables safe refactoring at scale
- Decorator support for advanced patterns
- Required for large-scale application development

---

## Build & Development Tools

### Vite (v7)
**What**: Next-generation frontend build tool with lightning-fast HMR (Hot Module Replacement).

**Who**:
- Created by Evan You (Vue.js creator)
- Maintained by Vite team and community

**When**:
- Released: 2020
- v7 (current): 2025
- Rapidly evolving with frequent updates

**Where**:
- Development server (dev mode)
- Production bundler (build mode)
- Configured in `electron.vite.config.ts`

**Why**:
- 10-100x faster than Webpack for dev startup
- Instant HMR regardless of app size
- Native ESM support
- Optimized production builds with Rollup
- Plugin ecosystem for React, TypeScript
- SWC integration for even faster compilation

---

### electron-vite
**What**: Vite-based build tool specifically designed for Electron applications.

**Who**:
- Electron community tool
- Optimized for Electron's multi-process architecture

**When**:
- Released: ~2022
- Actively maintained

**Where**:
- Builds main, preload, and renderer processes separately
- Configured in `electron.vite.config.ts`

**Why**:
- Proper handling of Electron's three-process model
- Automatic externalization of Node.js dependencies
- Optimized HMR for Electron apps
- Better DX than manual Vite configuration

---

### pnpm (Package Manager)
**What**: Fast, disk-efficient package manager using hard links and content-addressable storage.

**Who**:
- Created by Zoltan Kochan
- Used by: Microsoft, Vue.js, Prisma

**When**:
- Released: 2016
- Currently mainstream alternative to npm/yarn

**Where**:
- `pnpm-lock.yaml` (lockfile)
- `node_modules/` (symlinked structure)
- Workspace management for monorepo

**Why**:
- 2x faster than npm
- Saves disk space (one copy per version globally)
- Strict dependency resolution (no phantom dependencies)
- Native monorepo/workspace support
- Better security with isolated dependencies

---

### electron-builder (v25)
**What**: Complete solution to package and build Electron apps for distribution.

**Who**:
- Community-driven project
- Standard tool for Electron packaging

**When**:
- Released: 2016
- Continuously maintained

**Where**:
- Configured in `electron-builder.yml`
- Creates installers in `dist/`

**Why**:
- Auto-update support
- Code signing and notarization
- Platform-specific installers (DMG, NSIS, AppImage)
- ASAR packaging with smart unpacking
- Easy CI/CD integration

---

## UI & Styling

### TailwindCSS (v4)
**What**: Utility-first CSS framework for rapid UI development.

**Who**:
- Created by Adam Wathan and Steve Schoger
- Used by: GitHub, Netflix, NASA

**When**:
- Released: 2017
- v4 (latest): 2024-2025
- Major rewrite with native Rust engine

**Where**:
- `tailwind.config.js`
- Applied via className in React components
- Global styles in `src/styles/globals.css`

**Why**:
- Rapid prototyping with utility classes
- No CSS file bloat (tree-shaking)
- Consistent design system
- Responsive design made easy
- Better than writing custom CSS repeatedly
- v4 is 10x faster with Rust compiler

---

### shadcn/ui
**What**: A collection of re-usable components built with Radix UI and Tailwind.

**Who**:
- Created by shadcn (Hassan El Mghari)
- Not a component library - copy-paste components

**When**:
- Released: 2023
- Rapidly became industry standard

**Where**:
- `components.json` (configuration)
- Components in `src/renderer/src/components/ui/`
- Uses Radix UI primitives underneath

**Why**:
- Own your components (not a dependency)
- Built on accessible primitives (Radix UI)
- Customizable with Tailwind
- TypeScript-first
- "New York" style - modern, professional aesthetic
- No runtime library dependency

---

### Radix UI
**What**: Unstyled, accessible UI primitives for building design systems.

**Who**:
- Created by Modulz team (now WorkOS)
- Used by: Vercel, Linear, Tailwind Labs

**When**:
- Released: 2020
- Stable and mature

**Where**:
- Used as foundation for shadcn/ui components
- Primitives: Select, Avatar, Tooltip, ScrollArea, etc.

**Why**:
- WAI-ARIA compliant (accessibility)
- Keyboard navigation built-in
- Unstyled (full styling control)
- Production-ready primitives
- Saves thousands of hours of accessibility work

---

### Arco Design
**What**: Enterprise-level React UI component library from ByteDance.

**Who**:
- Developed by ByteDance (TikTok parent company)
- Used internally at ByteDance

**When**:
- Released: 2021
- Actively maintained

**Where**:
- `@arco-design/web-react` in devDependencies
- Used alongside Tailwind/shadcn

**Why**:
- Enterprise-grade components
- Chinese/English i18n support
- Complex components (Table, Form, etc.)
- ByteDance's design language
- Complements shadcn/ui for complex scenarios

---

### Lucide Icons
**What**: Beautiful, consistent icon library (fork of Feather Icons).

**Who**:
- Community-driven project
- Used by: shadcn/ui, many modern apps

**When**:
- Forked: 2021
- 1000+ icons and growing

**Where**:
- `lucide-react` package
- Icon library for shadcn/ui
- Used throughout UI components

**Why**:
- Consistent design style
- Tree-shakeable (import only needed icons)
- React components (not SVG sprites)
- Active development (new icons regularly)
- Perfect match for modern UI design

---

## State Management & Data

### Jotai (v2.14)
**What**: Primitive and flexible state management library for React.

**Who**:
- Created by Daishi Kato (Poimandres collective)
- Used by: modern React apps moving away from Redux

**When**:
- Released: 2020
- Stable v2 released 2023

**Where**:
- Atom-based state throughout app
- Alternative to Redux for simpler state

**Why**:
- Minimal boilerplate (no reducers/actions)
- Atomic state approach
- Better TypeScript inference than Redux
- Bottom-up composition
- Excellent performance with automatic optimization
- React 19 compatible

---

### Redux Toolkit (v2.2)
**What**: Official, opinionated Redux toolset with simplified API.

**Who**:
- Official Redux team (Mark Erikson)
- Industry standard for complex state

**When**:
- Redux: 2015
- Redux Toolkit: 2019
- Still widely used

**Where**:
- Complex state management scenarios
- Used alongside Jotai in this project

**Why**:
- Predictable state updates
- DevTools for time-travel debugging
- Proven at scale (millions of apps)
- RTK simplifies Redux boilerplate
- Good for complex, structured state

---

### better-sqlite3 (v12)
**What**: Fastest SQLite3 library for Node.js with synchronous API.

**Who**:
- Community project
- Used in Electron apps needing local DB

**When**:
- Released: 2016
- Actively maintained

**Where**:
- Main process only (Node.js)
- Local database storage
- Requires native compilation (`electron-rebuild`)

**Why**:
- 2-5x faster than node-sqlite3 (synchronous)
- Full SQL support
- ACID transactions
- Perfect for Electron's main process
- No async complexity for simple queries

---

### Dexie.js (v4)
**What**: Wrapper library for IndexedDB with a minimalistic and straightforward API.

**Who**:
- Created by David Fahlander
- Used in web apps needing client-side DB

**When**:
- Released: 2014
- v4 released 2023

**Where**:
- Renderer process (browser context)
- `dexie-react-hooks` for React integration

**Why**:
- IndexedDB is complex - Dexie makes it simple
- React hooks integration
- TypeScript support
- Transactions and querying
- Offline-first capabilities

---

## Code Quality & Tooling

### ESLint (v9)
**What**: Pluggable linting tool for identifying and fixing JavaScript/TypeScript problems.

**Who**:
- Created by Nicholas C. Zakas
- Industry standard

**When**:
- Released: 2013
- v9 (flat config): 2024

**Where**:
- `eslint.config.mjs` (new flat config format)
- Runs on save, pre-commit, CI/CD

**Why**:
- Catch bugs before runtime
- Enforce code style consistency
- Auto-fix many issues
- Custom rules (e.g., enforce LoggerService usage)
- TypeScript support
- React hooks validation

---

### Prettier (v3.6)
**What**: Opinionated code formatter supporting multiple languages.

**Who**:
- Created by James Long
- Adopted by most modern projects

**When**:
- Released: 2017
- v3 released 2023

**Where**:
- Configured in `.prettierrc.yaml`
- Integrates with ESLint
- Auto-format on save

**Why**:
- Stop arguing about code style
- Consistent formatting across team
- Supports JSON, Markdown, YAML, etc.
- Editor integration
- Reduces code review friction

---

### Code Inspector Plugin
**What**: Vite plugin allowing click-to-source from browser to editor.

**Who**:
- Community tool for better DX

**When**:
- Modern development tool (2023+)

**Where**:
- Dev mode only in `electron.vite.config.ts`
- Browser → VSCode integration

**Why**:
- Click DOM element → jump to source code
- Saves time during debugging
- Better developer experience
- No manual file searching

---

## AI & Backend Integration

### Vercel AI SDK (v5)
**What**: TypeScript toolkit for building AI-powered applications with streaming support.

**Who**:
- Created by Vercel
- Used in modern AI apps

**When**:
- Released: 2023
- v5 (current): 2024-2025

**Where**:
- `ai` and `@ai-sdk/react` packages
- AI streaming and chat interfaces
- `@ai-sdk/openai-compatible` for API integration

**Why**:
- Streaming responses from LLMs
- React hooks for AI chat UIs
- Framework-agnostic core
- OpenAI/Anthropic/custom provider support
- Type-safe AI interactions
- Built for production use

---

### Python Backend Integration
**What**: Python executables bundled with Electron app for specialized tasks.

**Who**:
- Custom implementation for this project

**When**:
- Built during app compilation

**Where**:
- `build-python.js` / `build-python.sh`
- `externals/python/` directory
- Packaged in `extraResources`

**Why**:
- Python better for certain tasks (ML, system automation)
- Leverage Python ecosystem
- `window_inspector` and `window_capture` tools
- Native system integration
- Separation of concerns (Node.js ↔ Python)

---

## Additional Technologies

### Other Notable Dependencies

#### **React Router (v6)**
- **What**: Declarative routing for React applications
- **Why**: Client-side navigation, nested routes, URL state management

#### **React Hooks (ahooks, react-hotkeys-hook)**
- **What**: Collections of useful React hooks
- **Why**: Keyboard shortcuts, lifecycle management, common patterns

#### **i18next (react-i18next)**
- **What**: Internationalization framework
- **Why**: Multi-language support (EN/CN), translation management

#### **Express.js (v5)**
- **What**: Web server framework for Node.js
- **Why**: Internal API server in main process, local development proxy

#### **electron-store**
- **What**: Simple data persistence for Electron apps
- **Why**: User preferences, settings, key-value storage

#### **electron-updater**
- **What**: Auto-update functionality for Electron apps
- **Why**: Seamless app updates, delta downloads

#### **winston (Logger)**
- **What**: Versatile logging library for Node.js
- **Why**: Structured logging, log rotation, multiple transports

---

## Technology Selection Philosophy

### **Why These Technologies?**

1. **Modern Stack**: Bleeding-edge tools (React 19, Vite 7, TypeScript 5.8)
2. **Performance**: Fast build times (Vite), fast runtime (better-sqlite3, pnpm)
3. **Developer Experience**: HMR, TypeScript, ESLint, Prettier, code inspector
4. **Production-Ready**: Electron-builder, auto-updates, logging, error handling
5. **Scalability**: Monorepo (workspaces), modular architecture
6. **Accessibility**: Radix UI primitives, shadcn/ui
7. **AI-First**: Vercel AI SDK for LLM integration
8. **Cross-Platform**: Electron + Python for macOS, Windows, Linux

### **When to Use This Stack?**

- Building cross-platform desktop applications
- Need native system access (files, screenshots, OS features)
- AI/LLM integration required
- Complex local data storage (SQL + IndexedDB)
- Enterprise-grade UI requirements
- Need auto-update capabilities
- TypeScript-first development

---

## References & Documentation

- **Electron**: https://www.electronjs.org/
- **React**: https://react.dev/
- **Vite**: https://vite.dev/
- **TailwindCSS**: https://tailwindcss.com/
- **shadcn/ui**: https://ui.shadcn.com/
- **TypeScript**: https://www.typescriptlang.org/
- **Jotai**: https://jotai.org/
- **Vercel AI SDK**: https://sdk.vercel.ai/

---

**Last Updated**: 2026-01-31
**Project**: MineContext v0.1.5
**Target Platforms**: macOS, Windows, Linux
