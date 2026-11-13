import os
import re

files = [
    "lib/screens/nqueens/nqueens_visualizer_screen.dart",
    "lib/screens/nqueens/nqueens_manual_screen.dart",
    "lib/screens/maze/maze_visualizer_screen.dart",
    "lib/screens/maze/maze_manual_screen.dart",
    "lib/screens/leaderboard/leaderboard_screen.dart",
    "lib/screens/challenge/timed_challenge_screen.dart",
    "lib/screens/practice/practice_hub_screen.dart",
    "lib/screens/progress/progress_screen.dart",
    "lib/screens/learning/lesson_list_screen.dart",
    "lib/screens/learning/lesson_detail_screen.dart"
]

base_dir = r"C:\Project\Backtrack Visualization\backtrackx_new"

home_button = """IconButton(
  icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: cs.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.home_rounded, color: cs.primary, size: 20),
  ),
  tooltip: 'Go to Home',
  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.dashboard, (route) => false),
)"""

leading_button = """leading: IconButton(
  icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: cs.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.arrow_back_ios_new_rounded, color: cs.primary, size: 18),
  ),
  tooltip: 'Back',
  onPressed: () => Navigator.of(context).pop(),
)"""


for f in files:
    filepath = os.path.join(base_dir, f)
    with open(filepath, "r", encoding="utf-8") as file:
        content = file.read()
    
    # 1. Ensure AppRoutes is imported
    if "import '../../routes/app_routes.dart';" not in content and "import" in content:
        import_idx = content.rfind("import '")
        end_idx = content.find(";", import_idx) + 1
        content = content[:end_idx] + "\nimport '../../routes/app_routes.dart';" + content[end_idx:]
    
    # 2. Add `final cs = Theme.of(context).colorScheme;` in build method if needed
    if "final cs = Theme.of(context).colorScheme;" not in content:
        build_idx = content.find("Widget build(BuildContext context) {")
        if build_idx != -1:
            end_brace_idx = content.find("{", build_idx) + 1
            content = content[:end_brace_idx] + "\n    final cs = Theme.of(context).colorScheme;" + content[end_brace_idx:]

    # 3. Add leading button if missing and remove existing leading if any.
    appbar_match = re.search(r"AppBar\(", content)
    if appbar_match:
        appbar_idx = appbar_match.end()
        # Find if leading exists inside AppBar
        # We need to make sure we only look inside the AppBar definition
        appbar_content = content[appbar_idx:appbar_idx+400]
        if "leading:" in appbar_content:
            leading_pattern = re.compile(r"leading:\s*IconButton\([\s\S]*?onPressed:[^,]*?,?\s*\),?")
            content = leading_pattern.sub(leading_button + ",", content)
        else:
            content = content[:appbar_idx] + "\n        " + leading_button + "," + content[appbar_idx:]

    # 4. Add home button to actions
    actions_match = re.search(r"actions:\s*\[", content)
    if actions_match:
        # First remove old home button
        old_home_pattern = re.compile(r"IconButton\([\s\S]*?icon:\s*const\s*Icon\(Icons\.home\)[\s\S]*?onPressed:.*?pushNamedAndRemoveUntil[\s\S]*?\),?")
        content = old_home_pattern.sub("", content)

        actions_match2 = re.search(r"actions:\s*\[", content)
        actions_idx = actions_match2.end()
        content = content[:actions_idx] + "\n          " + home_button + "," + content[actions_idx:]
    else:
        # Actions doesn't exist, insert actions: [home_button]
        title_match = re.search(r"title:\s*[^,]+,", content)
        if title_match:
            title_idx = title_match.end()
            content = content[:title_idx] + "\n        actions: [\n          " + home_button + ",\n        ]," + content[title_idx:]
    
    with open(filepath, "w", encoding="utf-8") as file:
        file.write(content)
        
print("Done")
