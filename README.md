# Nx + Next.js + shadcn/ui

This guide will help you set up a [Nx](https://github.com/nrwl/nx) monorepo with [Next.js](https://github.com/vercel/next.js) and shared [shadcn/ui](https://github.com/shadcn-ui/ui) library support.

## Create a new Nx workspace

```bash
npx create-nx-workspace@latest nx-next-shadcn --pm=pnpm

✔ Which stack do you want to use? # none
✔ Package-based monorepo, integrated monorepo, or standalone project? # integrated
✔ Which CI provider would you like to use? # (pick the one you like)
```

```bash
cd nx-next-shadcn
```

## Next.js App

### Add a Next.js application

```bash
nx add @nx/next
nx add @nx/react # for jest config
nx g @nx/next:app web --directory=apps/web --projectNameAndRootFormat=as-provided --style=tailwind --appDir=true --src=true
```

Maybe you need to install the dependencies for Playwright:

```bash
npx playwright install-deps
```

### More Prettier (optional)

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

## shadcn/ui Lib

### Create a new library

```bash
nx g @nx/next:lib shadcn --directory=libs/shadcn --projectNameAndRootFormat=as-provided --component=false --style=css
```

### Remove unnecessary files (optional)

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

### Initialize shadcn/ui

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

Merging properties from the export of [`libs/shadcn/tailwind.config.js`](/libs/shadcn/tailwind.config.js) (excluding the `content` field) into the export of tailwind config files in your Next.js apps.

Also, merge the content of [`libs/shadcn/global.css`](/libs/shadcn/global.css) into the global CSS files in your Next.js apps and keep the rules you need.

> See the [apps/web/tailwind.config.js](/apps/web/tailwind.config.js) and [apps/web/src/app/global.css](/apps/web/src/app/global.css) for reference.

### Add shadcn-ui components

Prepare the re-exporting script:

```bash
curl -LO https://github.com/OoadadaoO/nx-next-shadcn/releases/download/v0.0.1/post-add.sh
chmod +x ./post-add.sh
```

Run the following commands to _completely install_ the components:

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
