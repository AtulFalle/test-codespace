
# Create a complete setup script that users can run
setup_script = '''#!/bin/bash

# Nx 21 + Angular 20 + PrimeNG + Tailwind + Storybook Setup Script
# Run this script to create a complete working setup

echo "🚀 Starting Nx Design System Setup..."
echo ""

# Step 1: Create Nx workspace
echo "📦 Step 1/7: Creating Nx workspace..."
npx create-nx-workspace@21 nx-design-system --preset=apps --nxCloud=skip --packageManager=npm
cd nx-design-system

# Step 2: Install Angular plugin
echo "📦 Step 2/7: Installing Angular plugin..."
npm install -D @nx/angular@21

# Step 3: Generate library
echo "📦 Step 3/7: Generating design system library..."
npx nx g @nx/angular:library design-theme \\
  --directory=libs/design-theme \\
  --buildable \\
  --publishable \\
  --importPath=@my-org/design-theme \\
  --standalone \\
  --style=scss \\
  --skipTests \\
  --no-interactive

# Step 4: Install dependencies
echo "📦 Step 4/7: Installing PrimeNG, Tailwind, and other dependencies..."
npm install primeng@20 @primeuix/themes primeicons @angular/animations
npm install -D tailwindcss@4 @tailwindcss/postcss postcss autoprefixer

# Step 5: Setup Storybook
echo "📦 Step 5/7: Installing and configuring Storybook..."
npm install -D @nx/storybook@21
npx nx g @nx/angular:storybook-configuration design-theme \\
  --interactionTests=true \\
  --generateStories=true \\
  --no-interactive

# Step 6: Create configuration files
echo "📦 Step 6/7: Creating configuration files..."

# Create PostCSS config
cat > libs/design-theme/.postcssrc.json << 'EOF'
{
  "plugins": {
    "@tailwindcss/postcss": {}
  }
}
EOF

# Create Tailwind config
cat > libs/design-theme/tailwind.config.js << 'EOF'
const { createGlobPatternsForDependencies } = require('@nx/angular/tailwind');
const { join } = require('path');

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    join(__dirname, 'src/**/*.{html,ts}'),
    ...createGlobPatternsForDependencies(__dirname),
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
      },
    },
  },
  plugins: [],
};
EOF

# Create styles file
cat > libs/design-theme/src/lib/styles.scss << 'EOF'
// Import Tailwind CSS
@import "tailwindcss";

// Import PrimeNG icons
@import "primeicons/primeicons.css";

// CSS Layer ordering
@layer tailwind-base, primeng, tailwind-utilities;

* {
  box-sizing: border-box;
}
EOF

# Create design theme config
cat > libs/design-theme/src/lib/design-theme.config.ts << 'EOF'
import { ApplicationConfig } from '@angular/core';
import { provideAnimations } from '@angular/platform-browser/animations';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeuix/themes/aura';

export const designThemeConfig: ApplicationConfig = {
  providers: [
    provideAnimations(),
    providePrimeNG({
      theme: {
        preset: Aura,
        options: {
          prefix: 'p',
          darkModeSelector: '.dark',
          cssLayer: {
            name: 'primeng',
            order: 'tailwind-base, primeng, tailwind-utilities'
          }
        }
      }
    })
  ]
};
EOF

# Update Storybook preview
cat > libs/design-theme/.storybook/preview.ts << 'EOF'
import { Preview, applicationConfig } from '@storybook/angular';
import { provideAnimations } from '@angular/platform-browser/animations';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeuix/themes/aura';

// CRITICAL: Import styles for Tailwind and PrimeNG
import '../src/lib/styles.scss';

const preview: Preview = {
  decorators: [
    applicationConfig({
      providers: [
        provideAnimations(),
        providePrimeNG({
          theme: {
            preset: Aura,
            options: {
              prefix: 'p',
              darkModeSelector: '.dark',
              cssLayer: {
                name: 'primeng',
                order: 'tailwind-base, primeng, tailwind-utilities'
              }
            }
          }
        })
      ],
    }),
  ],
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
    },
  },
};

export default preview;
EOF

# Step 7: Generate Button component
echo "📦 Step 7/7: Creating Button component..."
npx nx g @nx/angular:component button \\
  --project=design-theme \\
  --export \\
  --standalone \\
  --inlineStyle=false \\
  --inlineTemplate=false \\
  --no-interactive

# Create button component TypeScript
cat > libs/design-theme/src/lib/button/button.component.ts << 'EOF'
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';

export type ButtonVariant = 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info';
export type ButtonSize = 'small' | 'medium' | 'large';

@Component({
  selector: 'ds-button',
  standalone: true,
  imports: [CommonModule, ButtonModule],
  templateUrl: './button.component.html',
  styleUrls: ['./button.component.scss']
})
export class ButtonComponent {
  @Input() label: string = 'Button';
  @Input() variant: ButtonVariant = 'primary';
  @Input() size: ButtonSize = 'medium';
  @Input() disabled: boolean = false;
  @Input() loading: boolean = false;
  @Input() icon?: string;
  @Input() iconPos: 'left' | 'right' = 'left';

  get buttonClass(): string {
    const classes = ['ds-button'];
    
    if (this.size === 'small') {
      classes.push('text-sm', 'px-3', 'py-2');
    } else if (this.size === 'large') {
      classes.push('text-lg', 'px-6', 'py-3');
    } else {
      classes.push('text-base', 'px-4', 'py-2');
    }
    
    return classes.join(' ');
  }

  get severityClass(): string {
    const severityMap: Record<ButtonVariant, string> = {
      primary: '',
      secondary: 'p-button-secondary',
      success: 'p-button-success',
      danger: 'p-button-danger',
      warning: 'p-button-warning',
      info: 'p-button-info'
    };
    return severityMap[this.variant];
  }
}
EOF

# Create button component HTML
cat > libs/design-theme/src/lib/button/button.component.html << 'EOF'
<p-button 
  [label]="label"
  [disabled]="disabled"
  [loading]="loading"
  [icon]="icon"
  [iconPos]="iconPos"
  [class]="buttonClass + ' ' + severityClass"
  [severity]="variant === 'primary' ? undefined : variant">
</p-button>
EOF

# Create button component SCSS
cat > libs/design-theme/src/lib/button/button.component.scss << 'EOF'
.ds-button {
  @apply rounded-md transition-all duration-200 font-medium;
  
  &:hover:not(:disabled) {
    @apply shadow-md transform scale-105;
  }
  
  &:active:not(:disabled) {
    @apply scale-95;
  }
}
EOF

# Create comprehensive button stories
cat > libs/design-theme/src/lib/button/button.component.stories.ts << 'EOF'
import { Meta, StoryObj, moduleMetadata, applicationConfig } from '@storybook/angular';
import { provideAnimations } from '@angular/platform-browser/animations';
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeuix/themes/aura';
import { ButtonComponent } from './button.component';

const meta: Meta<ButtonComponent> = {
  title: 'Design System/Button',
  component: ButtonComponent,
  tags: ['autodocs'],
  decorators: [
    moduleMetadata({
      imports: [ButtonComponent],
    }),
    applicationConfig({
      providers: [
        provideAnimations(),
        providePrimeNG({
          theme: {
            preset: Aura
          }
        })
      ],
    }),
  ],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info'],
    },
    size: {
      control: 'radio',
      options: ['small', 'medium', 'large'],
    },
    disabled: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
  },
};

export default meta;
type Story = StoryObj<ButtonComponent>;

export const Primary: Story = {
  args: {
    label: 'Primary Button',
    variant: 'primary',
    size: 'medium',
  },
};

export const Secondary: Story = {
  args: {
    label: 'Secondary Button',
    variant: 'secondary',
    size: 'medium',
  },
};

export const Success: Story = {
  args: {
    label: 'Success Button',
    variant: 'success',
    size: 'medium',
  },
};

export const Danger: Story = {
  args: {
    label: 'Danger Button',
    variant: 'danger',
    size: 'medium',
  },
};

export const WithIcon: Story = {
  args: {
    label: 'With Icon',
    variant: 'primary',
    icon: 'pi pi-check',
    size: 'medium',
  },
};

export const Loading: Story = {
  args: {
    label: 'Loading',
    variant: 'primary',
    loading: true,
    size: 'medium',
  },
};

export const Disabled: Story = {
  args: {
    label: 'Disabled',
    variant: 'primary',
    disabled: true,
    size: 'medium',
  },
};

export const AllVariants: Story = {
  render: () => ({
    template: `
      <div class="flex flex-col gap-4 p-4 bg-gray-50">
        <h3 class="text-xl font-bold">Variants</h3>
        <div class="flex gap-2 flex-wrap">
          <ds-button label="Primary" variant="primary"></ds-button>
          <ds-button label="Secondary" variant="secondary"></ds-button>
          <ds-button label="Success" variant="success"></ds-button>
          <ds-button label="Danger" variant="danger"></ds-button>
          <ds-button label="Warning" variant="warning"></ds-button>
          <ds-button label="Info" variant="info"></ds-button>
        </div>
        
        <h3 class="text-xl font-bold">Sizes</h3>
        <div class="flex gap-2 flex-wrap items-center">
          <ds-button label="Small" size="small"></ds-button>
          <ds-button label="Medium" size="medium"></ds-button>
          <ds-button label="Large" size="large"></ds-button>
        </div>
        
        <h3 class="text-xl font-bold">States</h3>
        <div class="flex gap-2 flex-wrap">
          <ds-button label="With Icon" icon="pi pi-check"></ds-button>
          <ds-button label="Loading" [loading]="true"></ds-button>
          <ds-button label="Disabled" [disabled]="true"></ds-button>
        </div>
      </div>
    `,
  }),
};
EOF

# Update library index.ts
cat > libs/design-theme/src/index.ts << 'EOF'
// Export components
export * from './lib/button/button.component';

// Export configuration
export * from './lib/design-theme.config';
EOF

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🎉 Your Nx design system is ready!"
echo ""
echo "Next steps:"
echo "1. cd nx-design-system"
echo "2. Run Storybook: npm run storybook"
echo "3. Open http://localhost:4400"
echo ""
echo "Available commands:"
echo "  npm run storybook        - Run Storybook (port 4400)"
echo "  npm run build            - Build the library"
echo "  npm run build-storybook  - Build Storybook for production"
echo ""
echo "Happy coding! 🚀"
'''

# Save the setup script
with open('setup-nx-design-system.sh', 'w') as f:
    f.write(setup_script)

print("✅ Complete setup script created: setup-nx-design-system.sh")
print("\nThis script will:")
print("  1. Create Nx workspace")
print("  2. Install all dependencies")
print("  3. Configure Tailwind, PrimeNG, and Storybook")
print("  4. Create a complete Button component with stories")
print("  5. Set up all configuration files")
