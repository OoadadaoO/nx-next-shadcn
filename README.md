# Nx + Next.js + shadcn/ui

<!-- Result: Once the shadcn library is initialized according to [Step 3](#3-shadcnui-lib), you can add more shadcn/ui components by the cli and simple check in [Step 3.5](#35-add-shadcnui-components). -->

This guide will helps you build an [Nx](https://github.com/nrwl/nx) monorepo with [Next.js](https://github.com/vercel/next.js) and a shared [shadcn/ui](https://github.com/shadcn-ui/ui) library.

After following this guide, you'll have an Nx monorepo with a working shadcn/ui library that allows easy addition of components via CLI and simple check.

## Versions

- Nx: 19.5.3
- pnpm: 9.5.0
- Next.js: 14.2.3

## Getting Started

### Nx Workspace

Create a new Nx workspace with the following settings,

```bash
npx create-nx-workspace@latest nx-next-shadcn --pm=pnpm

✔ Which stack do you want to use? # none
✔ Package-based monorepo, integrated monorepo, or standalone project? # integrated
✔ Which CI provider would you like to use? # (pick the one you like)
```

```bash
cd nx-next-shadcn
```

### Next.js App

#### 2-1 Initialization

Install the necessary packages and add a Next.js application,

```bash
nx add @nx/next
nx add @nx/react # for jest config
nx g @nx/next:app web --directory=apps/web --projectNameAndRootFormat=as-provided --style=tailwind --appDir=true --src=true
```

You might need to install the dependencies for Playwright if you want to use it,

```bash
npx playwright install-deps
```

#### 2-2 _(optional)_ More Prettier

Install the necessary packages,

```bash
pnpm add -D prettier@3 prettier-plugin-tailwindcss @trivago/prettier-plugin-sort-imports
```

Edit [`.prettierignore`](.prettierignore),

```diff
+ pnpm-lock.yaml
```

Edit [`.prettierrc`](.prettierrc),

```json
{
  "plugins": ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
  "importOrder": ["^react", "^next", "<THIRD_PARTY_MODULES>", "^@[^\\/]*", "^[..\\/]", "^[.\\/]"],
  "importOrderSeparation": true
}
```

Test formatting,

```bash
nx format
```

### shadcn/ui Library

#### 3.1 Initialization

```bash
nx g @nx/next:lib shadcn --directory=libs/shadcn --projectNameAndRootFormat=as-provided --component=false --style=css
```

#### 3.2 _(optional)_ Cleanup

Remove Unnecessary Files,

```bash
rm libs/shadcn/src/server.ts libs/shadcn/src/lib/hello-server.tsx
```

Edit root [`tsconfig.base.json`](tsconfig.base.json),

```diff
{
  "compilerOptions": {
    "paths": {
      "@nx/shadcn": ["libs/shadcn/src/index.ts"],
-     "@nx/shadcn/server": ["libs/shadcn/src/server.ts"]
    }
}
```

#### 3.3 Download Script

```bash
curl -LO https://github.com/OoadadaoO/nx-next-shadcn/releases/download/v0.0.1/post-add.sh
chmod +x ./post-add.sh
```

#### 3.4 Prerequisites for shadcn/ui CLI

Copy the following files to your monorepo:

| Source                                             | Destination                 | Purpose           |
| -------------------------------------------------- | --------------------------- | ----------------- |
| [tsconfig.json](/tsconfig.json)                    | monorepo root               | CLI               |
| [components.json](/components.json)                | monorepo root               | CLI               |
| [tailwind.config.js](/apps/web/tailwind.config.js) | `apps/<next-apps>/`         | TailwindCSS       |
| [global.css](/apps/web/src/app/global.css)         | `apps/<next-apps>/src/app/` | CSS               |
| [utils.ts](/libs/shadcn/src/lib/utils.ts)          | `libs/shadcn/src/lib`       | Utility functions |

Install the necessary packages,

```bash
pnpm add tailwindcss-animate class-variance-authority clsx tailwind-merge
pnpm add lucide-react
```

#### 3.4b Alternative: Manual Setup

> The following steps are more dependent on the shadcn/ui official CLI and your preferences.

Prepare the necessary files,

```bash
touch tailwind.config.js
echo '{
  "_COMMENT": "only used by shadcn/ui cli",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["libs/shadcn/src/*"]
    }
  }
}' > tsconfig.json
```

Initialize shadcn/ui by CLI,

```bash
pnpm dlx shadcn-ui@latest init

# '↵' means press the Enter key to use the default value.

✔ Would you like to use TypeScript (recommended)? # ↵ (yes)
✔ Which style would you like to use? # (pick the one you like)
✔ Which color would you like to use as base color? # (pick the one you like)
✔ Where is your global CSS file? # libs/shadcn/global.css
✔ Would you like to use CSS variables for colors? # ↵ (yes)
✔ Are you using a custom tailwind prefix eg. tw-? (Leave blank if not) # ↵ (blank)
✔ Where is your tailwind.config.js located? # libs/shadcn/tailwind.config.js
✔ Configure the import alias for components: # ↵ (@/components)
✔ Configure the import alias for utils: # ↵ (@/lib/utils)
✔ Are you using React Server Components? # ↵ (yes)
✔ Write configuration to components.json. Proceed? # Y
```

Modify the files in your Next.js apps,

- `/apps/<next-apps>/tailwind.config.js`: Merge the properties from the export of [`libs/shadcn/tailwind.config.js`](/libs/shadcn/tailwind.config.js), excluding the `content` field.

- `/apps/<next-apps>/src/app/global.css`: Merge the content of [`libs/shadcn/global.css`](/libs/shadcn/global.css) and keep the css rules you need.

> See the [apps/web/tailwind.config.js](/apps/web/tailwind.config.js) and [apps/web/src/app/global.css](/apps/web/src/app/global.css) for reference.

## Usage

### Add shadcn/ui Components

_**Completely install**_ the components,

```bash
pnpm dlx shadcn-ui@latest add # choose the components you need
./post-add.sh libs/shadcn # Usage: ./post-add.sh <target-path>
nx format
```

Open and check [`libs/shadcn/src/components/ui/index.ts`](/libs/shadcn/src/components/ui/index.ts) and maybe you will encounter a **naming conflict (TS2308)** when re-exporting the component functions.

> It's recommended to edit the export names in the components file rather than that in the re-export file.
>
> For example, [`toaster.tsx`](/libs/shadcn/src/components/ui/toaster.tsx) and [`sonner.tsx`](/libs/shadcn/src/components/ui/sonner.tsx) both export a function named `Toaster`. To avoid naming conflicts, you can rewrite the export in the `sonner.tsx`:

```diff
- export { Toaster };
+ export { Toaster as SonnerToaster };
```

### Use shadcn/ui Components

In your Next.js apps,

```tsx
import { Button } from "@nx-next-shadcn/shadcn";

export default function Home() {
  return (
    <div className="flex h-screen w-full flex-col items-center justify-center">
      <Button>Click me</Button>
    </div>
  );
}
```

## References

- the discussion in the [shadcn/ui GitHub Issue #778](https://github.com/shadcn/ui/issues/778)
- [anteqkois/shadcn-nx-nextjs-boilerplate](https://github.com/anteqkois/shadcn-nx-nextjs-boilerplate)
- [brunos3d/shadcn-ui-nx-next](https://github.com/brunos3d/shadcn-ui-nx-next)
