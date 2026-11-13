const fs = require('fs');
const path = require('path');

function processDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            processDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            let original = content;
            // Remove const before common widgets
            const regex = /const\s+(Text|Icon|Divider|Container|SizedBox|Padding|Row|Column|EdgeInsets|BorderSide|TextStyle|Color|BoxDecoration|Center|Expanded|Stack)\b/g;
            content = content.replace(regex, '$1');
            if (content !== original) {
                fs.writeFileSync(fullPath, content);
                console.log(`Fixed consts in ${fullPath}`);
            }
        }
    }
}

processDir(path.join(__dirname, '../lib'));
