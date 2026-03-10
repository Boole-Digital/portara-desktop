with open('/opt/ancientOracle/static/app.js', 'r') as f:
    content = f.read()

# Fix escaped exclamation
content = content.replace('(80% off\\!)', '(80% off!)')

# The em dash character
em = '\u2014'

# Fix missing dollar amounts
content = content.replace(f"'Pay  {em} Start Scan (80% off!)'", f"'Pay $1 {em} Start Scan (80% off!)'")
content = content.replace(f"'Pay  {em} Start Scan'", f"'Pay $5 {em} Start Scan'")

with open('/opt/ancientOracle/static/app.js', 'w') as f:
    f.write(content)
print('Fixed')
