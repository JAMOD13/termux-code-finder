#!/data/data/com.termux/files/usr/bin/bash

clear
echo -e "\033[1;35m=======================================\033[0m"
echo -e "\033[1;36m    🚀 SETTING UP PRO AI WEB APP UI    \033[0m"
echo -e "\033[1;35m=======================================\033[0m"

# Dependencies install karna
if ! command -v python &> /dev/null; then
    pkg install python -y
fi

# Web UI ke liye Flask library install karna
pip install flask --quiet

# Core Application File (bot.py) Create Karna
cat << 'PYEOF' > bot.py
import os
import re
import json
import urllib.request
import urllib.parse
from flask import Flask, render_template_string, request, jsonify

app = Flask(__name__)

# Front-End HTML/CSS (Premium Dark Theme UI)
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pro AI Code Finder Dashboard</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0d1117;
            color: #c9d1d9;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 900px;
            margin: auto;
            background: #161b22;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5);
            border: 1px solid #30363d;
        }
        h1 {
            color: #58a6ff;
            text-align: center;
            margin-bottom: 20px;
        }
        .search-box {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
        }
        input[type="text"] {
            flex: 1;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #30363d;
            background-color: #0d1117;
            color: white;
            font-size: 16px;
        }
        button {
            padding: 12px 24px;
            background-color: #238636;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 16px;
        }
        button:hover { background-color: #2ea043; }
        .result-card {
            background: #0d1117;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            border: 1px solid #30363d;
        }
        .source-url { color: #58a6ff; font-size: 14px; word-break: break-all; }
        pre {
            background: #161b22;
            padding: 15px;
            border-radius: 6px;
            overflow-x: auto;
            border: 1px solid #30363d;
            color: #79c0ff;
            font-family: 'Courier New', Courier, monospace;
        }
        .status-msg { color: #56d364; font-weight: bold; margin-top: 10px; }
        .loader { display: none; text-align: center; color: #8b949e; font-style: italic; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🤖 PRO AI CODE FINDER</h1>
        <div class="search-box">
            <input type="text" id="query" placeholder="Kiski coding chahiye? (e.g., Responsive HTML Login Form)">
            <button onclick="searchCode()">Search Code</button>
        </div>
        
        <div id="loader" class="loader">🔍 Internet par behtareen sources se code dhoondha ja raha hai...</div>
        <div id="results"></div>
    </div>

    <script>
        async function searchCode() {
            const query = document.getElementById('query').value;
            if(!query) return alert('Kuch type toh karo bhai!');
            
            document.getElementById('loader').style.display = 'block';
            document.getElementById('results').innerHTML = '';
            
            try {
                const response = await fetch('/search', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'query=' + encodeURIComponent(query)
                });
                const data = await response.json();
                document.getElementById('loader').style.display = 'none';
                
                if(data.error) {
                    document.getElementById('results').innerHTML = `<div class='result-card' style='color:#f85149;'>❌ ${data.error}</div>`;
                    return;
                }
                
                document.getElementById('results').innerHTML = `
                    <div class="result-card">
                        <h3>✅ Sabse Best Source Mila!</h3>
                        <p class="source-url">🔗 <strong>Source:</strong> <a href="${data.url}" target="_blank">${data.url}</a></p>
                        <p class="status-msg">💾 ${data.message}</p>
                        <h4>💻 Code Preview:</h4>
                        <pre><code>${escapeHtml(data.code)}</code></pre>
                    </div>
                `;
            } catch(e) {
                document.getElementById('loader').style.display = 'none';
                alert('Server connection error!');
            }
        }
        function escapeHtml(text) {
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        }
    </script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

@app.route('/search', methods=['POST'])
def search():
    query = request.form.get('query', '')
    if not query:
        return jsonify({'error': 'Empty Query'})

    encoded_query = urllib.parse.quote(f"{query} code source file repository")
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    
    # Engine Search
    target_url = None
    try:
        lite_url = "https://lite.duckduckgo.com/lite/"
        data = urllib.parse.urlencode({'q': query}).encode('utf-8')
        lite_req = urllib.request.Request(lite_url, data=data, headers=headers)
        
        with urllib.request.urlopen(lite_req) as lite_resp:
            html_content = lite_resp.read().decode('utf-8', errors='ignore')
            all_links = re.findall(r'href="(https://[^"]+)"', html_content)
            for link in all_links:
                if any(domain in link for domain in ["github.com", "pastebin.com", "gist.github", "gitlab.com"]):
                    target_url = link
                    break
            if not target_url and all_links:
                target_url = all_links[0]
                
        if not target_url:
            return jsonify({'error': 'Internet par direct source repository nahi mili.'})

        # Formatting URLs for direct raw file extraction
        if "github.com" in target_url and "/blob/" in target_url:
            target_url = target_url.replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")

        # Content Fetching
        code_req = urllib.request.Request(target_url, headers=headers)
        with urllib.request.urlopen(code_req) as code_resp:
            raw_code = code_resp.read().decode('utf-8', errors='ignore')

        # Auto save path configurations
        download_path = "/sdcard/Download/Termux_Codes"
        os.makedirs(download_path, exist_ok=True)
        
        file_extension = "html" if "html" in query.lower() else "txt"
        file_clean_name = query.lower().replace(" ", "_")
        final_file_path = f"{download_path}/{file_clean_name}.{file_extension}"
        
        with open(final_file_path, "w", encoding="utf-8") as f:
            f.write(raw_code)

        return jsonify({
            'url': target_url,
            'code': raw_code[:5000],  # UI presentation limit
            'message': f"Aapka code phone ke Download folder me '{file_clean_name}.{file_extension}' naam se automatically save kar diya gaya hai!"
        })

    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    print("\n\033[1;32m[✓] Local Web Server active ho raha hai...")
    print("👉 Apne browser me kholiye: http://127.0.0.1:5000\033[0m\n")
    app.run(host='0.0.0.0', port=5000, debug=False)
PYEOF

python bot.py
