import urllib.request
import urllib.parse
import json
import re
import os

def universal_code_finder(query):
    print(f"\n[\033[1;34m🔍\033[0m] Poore Internet par '\033[1;36m{query}\033[0m' ka Code dhoondh raha hu...")
    
    # Anti-Block DuckDuckGo API API/Proxy Connection
    encoded_query = urllib.parse.quote(f"{query} code repository source file")
    url = f"https://api.duckduckgo.com/?q={encoded_query}&format=json&no_html=1"
    
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode('utf-8'))
            
        results = res_data.get('RelatedTopics', [])
        target_url = None
        
        for r in results:
            if 'FirstURL' in r:
                target_url = r['FirstURL']
                break
                
        # Deep Web Scraper Backup
        if not target_url:
            lite_url = f"https://lite.duckduckgo.com/lite/"
            data = urllib.parse.urlencode({'q': f"{query} source code github pastebin"}).encode('utf-8')
            lite_req = urllib.request.Request(lite_url, data=data, headers=headers)
            with urllib.request.urlopen(lite_req) as lite_resp:
                html_content = lite_resp.read().decode('utf-8', errors='ignore')
                all_links = re.findall(r'href="(https://[^"]+)"', html_content)
                for link in all_links:
                    if "github" in link or "pastebin" in link or "gist" in link or "stack" in link:
                        target_url = link
                        break
                if not target_url and all_links:
                    target_url = all_links[0]

        if not target_url:
            print("\033[1;31m❌ Maaf kijiye, internet par iska direct source nahi mila. Ek baar phir sahi keyword se try karein!\033[0m")
            return

        print(f"[\033[1;32m✓\033[0m] Best Source Mila: \033[1;33m{target_url}\033[0m")
        print(f"[\033[1;34m📥\033[0m] Real raw code download ho raha hai...")
        
        # GitHub URL Formatter (Web Page se direct Raw Code me badalna)
        if "github.com" in target_url and "/blob/" in target_url:
            target_url = target_url.replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")

        # Code Fetching
        code_req = urllib.request.Request(target_url, headers=headers)
        with urllib.request.urlopen(code_req) as code_resp:
            raw_code = code_resp.read().decode('utf-8', errors='ignore')

        print("\033[1;32m================= LIVE CODE PREVIEW =================\033[0m")
        print(raw_code[:1500]) # Screen par preview ke liye thoda sa code
        print("\033[1;32m=====================================================\033[0m\n")

        # Phone Storage Path Configuration
        download_path = "/sdcard/Download/Termux_Codes"
        os.makedirs(download_path, exist_ok=True)

        # File Naming Logic
        file_extension = "html" if "html" in query.lower() else "txt"
        file_clean_name = query.lower().replace(" ", "_")
        final_file_path = f"{download_path}/{file_clean_name}.{file_extension}"
        
        with open(final_file_path, "w", encoding="utf-8") as f:
            f.write(raw_code)
            
        print(f"\033[1;32m💾 Mubarek ho! Code direct aapke Phone ke Download folder me save ho gaya hai!\033[0m")
        print(f"📂 \033[1;34mFile Path:\033[0m {final_file_path}\n")

    except Exception as e:
        print(f"\033[1;31m❌ Kuch dikkat aayi: {e}\033[0m")

if __name__ == "__main__":
    print("\033[1;32m[✓] Bot System Active!\033[0m")
    q = input("\nAapko kis cheez ka code chahiye? (e.g. login html): ")
    if q.strip(): 
        universal_code_finder(q)
    else: 
        print("Aapne kuch type nahi kiya!")
