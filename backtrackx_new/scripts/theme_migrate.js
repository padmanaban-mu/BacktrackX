const fs = require('fs');
const path = require('path');

function processDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDir(fullPath);
        } else if (fullPath.endsWith('.dart') && !fullPath.includes('app_colors.dart') && !fullPath.includes('app.dart')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            let original = content;

            content = content.replace(/AppColors\.primary/g, 'Theme.of(context).colorScheme.primary');
            content = content.replace(/AppColors\.secondary/g, 'Theme.of(context).colorScheme.secondary');
            content = content.replace(/AppColors\.background/g, 'Theme.of(context).scaffoldBackgroundColor');
            content = content.replace(/AppColors\.surface/g, 'Theme.of(context).colorScheme.surface');
            content = content.replace(/AppColors\.error/g, 'Theme.of(context).colorScheme.error');
            content = content.replace(/AppColors\.success/g, 'Theme.of(context).colorScheme.tertiary');
            content = content.replace(/AppColors\.textPrimary/g, 'Theme.of(context).colorScheme.onSurface');
            content = content.replace(/AppColors\.textSecondary/g, 'Theme.of(context).colorScheme.onSurfaceVariant');

            if (content !== original) {
                fs.writeFileSync(fullPath, content);
                console.log(`Migrated AppColors in ${fullPath}`);
            }
        }
    }
}

processDir(path.join(__dirname, '../lib'));
