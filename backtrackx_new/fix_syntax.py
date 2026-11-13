import os

def fix_lesson_list():
    path = "lib/screens/learning/lesson_list_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    content = content.replace("), => Navigator.of(context).pop(),\n        ),", "),\n")
    
    extra_home = """          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard, 
                (route) => false
              );
            },
          ),"""
    content = content.replace(extra_home, "")
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def fix_lesson_detail():
    path = "lib/screens/learning/lesson_detail_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    content = content.replace("), => Navigator.of(context).pop(),\n        ),", "),\n")
    
    extra_home = """          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard, 
                (route) => false
              );
            },
          ),"""
    content = content.replace(extra_home, "")
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

def fix_practice_hub():
    path = "lib/screens/practice/practice_hub_screen.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    
    content = content.replace("title: const Text('Practice Hub',", "title: const Text('Practice Hub', style: TextStyle(fontWeight: FontWeight.bold)),")
    
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

fix_lesson_list()
fix_lesson_detail()
fix_practice_hub()
