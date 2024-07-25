# Nx + Next.js + shadcn/ui

This guide will help you set up a [Nx](https://github.com/nrwl/nx) monorepo with [Next.js](https://github.com/vercel/next.js) and shared [shadcn/ui](https://github.com/shadcn-ui/ui) library support.

> Once the shadcn library is initialized according to [3. shadcn/ui Lib](#3-shadcnui-lib), you can add more components by following the simple steps in [3.5 Add shadcn/ui components](#35-add-shadcnui-components) in the future.

## Inspiration & References

- the discussion in the [shadcn/ui GitHub Issue #778](https://github.com/shadcn/ui/issues/778)
- [anteqkois/shadcn-nx-nextjs-boilerplate](https://github.com/anteqkois/shadcn-nx-nextjs-boilerplate)
- [brunos3d/shadcn-ui-nx-next](https://github.com/brunos3d/shadcn-ui-nx-next)

## 1. Create a new Nx workspace

```bash
npx create-nx-workspace@latest nx-next-shadcn --pm=pnpm

✔ Which stack do you want to use? # none
✔ Package-based monorepo, integrated monorepo, or standalone project? # integrated
✔ Which CI provider would you like to use? # (pick the one you like)
```

```bash
cd nx-next-shadcn
```

## 2. Next.js App

### 2-1 Add a Next.js application

```bash
nx add @nx/next
nx add @nx/react # for jest config
nx g @nx/next:app web --directory=apps/web --projectNameAndRootFormat=as-provided --style=tailwind --appDir=true --src=true
```

Maybe you need to install the dependencies for Playwright:

```bash
npx playwright install-deps
```

### 2-2 More Prettier _(optional)_

Install the necessary packages:

```bash
pnpm add -D prettier@3 prettier-plugin-tailwindcss @trivago/prettier-plugin-sort-imports
```

Edit [`.prettierignore`](.prettierignore):

```diff
+ pnpm-lock.yaml
```

Edit [`.prettierrc`](.prettierrc):

```json
{
  "plugins": ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
  "importOrder": ["^react", "^next", "<THIRD_PARTY_MODULES>", "^@[^\\/]*", "^[..\\/]", "^[.\\/]"],
  "importOrderSeparation": true
}
```

Run formatting:

```bash
nx format
```

## 3. shadcn/ui Lib

### 3.1 Create a new library

```bash
nx g @nx/next:lib shadcn --directory=libs/shadcn --projectNameAndRootFormat=as-provided --component=false --style=css
```

### 3.2 Remove unnecessary files _(optional)_

```bash
rm libs/shadcn/src/server.ts libs/shadcn/src/lib/hello-server.tsx
```

Edit root [`tsconfig.base.json`](tsconfig.base.json):

```diff
{
  "compilerOptions": {
    "paths": {
      "@nx/shadcn": ["libs/shadcn/src/index.ts"],
-     "@nx/shadcn/server": ["libs/shadcn/src/server.ts"]
    }
}
```

### 3.3 Initialize shadcn/ui

> Alternatively, you can complete this initialization by copying the following files to your monorepo:
>
> | File                                               | Destination                 | Purpose           |
> | -------------------------------------------------- | --------------------------- | ----------------- |
> | [tsconfig.json](/tsconfig.json)                    | monorepo root               | CLI               |
> | [components.json](/components.json)                | monorepo root               | CLI               |
> | [tailwind.config.js](/apps/web/tailwind.config.js) | `apps/<next-apps>/`         | TailwindCSS       |
> | [global.css](/apps/web/src/app/global.css)         | `apps/<next-apps>/src/app/` | CSS               |
> | [utils.ts](/libs/shadcn/src/lib/utils.ts)          | `libs/shadcn/src/lib`       | Utility functions |
>
> And Install the necessary packages:
>
> ```bash
> pnpm add tailwindcss-animate class-variance-authority clsx tailwind-merge
> pnpm add lucide-react
> ```
>
> The following steps are more dependent on the shadcn/ui official CLI and your preferences.

Prepare the necessary files:

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

Initialize shadcn/ui by CLI:

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

Modify the files in your Next.js apps:

- Merging properties from the export of [`libs/shadcn/tailwind.config.js`](/libs/shadcn/tailwind.config.js) (excluding the `content` field) into the export of tailwind config files in your Next.js apps.

- Merge the content of [`libs/shadcn/global.css`](/libs/shadcn/global.css) into the global CSS files in your Next.js apps and keep the rules you need.

> See the [apps/web/tailwind.config.js](/apps/web/tailwind.config.js) and [apps/web/src/app/global.css](/apps/web/src/app/global.css) for reference.

### 3.4 Download script

```bash
curl -LO https://github.com/OoadadaoO/nx-next-shadcn/releases/download/v0.0.1/post-add.sh
chmod +x ./post-add.sh
```

### 3.5 Add shadcn/ui components

_**Completely install**_ the components:

```bash
pnpm dlx shadcn-ui@latest add # choose the components you need
./post-add.sh libs/shadcn # Usage: ./post-add.sh <target-path>
nx format
```

Check [`libs/shadcn/src/components/ui/index.ts`](/libs/shadcn/src/components/ui/index.ts) and maybe you will encounter a **naming conflict (TS2308)** when re-exporting the component functions.

> It's recommended to edit the export names in the components file rather than that in the re-export file.
> For example, `toaster.tsx` and `sonner.tsx` both export a function named `Toaster`. To avoid naming conflicts, you can rename the export in the `sonner.tsx`:

```diff
- export { Toaster };
+ export { Toaster as SonnerToaster };
```

## Usage

Now, you can use the components in your Next.js app:

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
