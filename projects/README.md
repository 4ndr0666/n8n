# 🧠 Social Profile Monitor v2.0 (n8n)

A modular, multi-platform OSINT automation workflow built in n8n to monitor and analyze activity across:

- LinkedIn
- Twitter/X
- Instagram
- TikTok
- Facebook
- Mastodon
- Pinterest
- Xenforo forums

## ⚙️ Modules Included

- Google Sheets integration for input/output
- Clearbit enrichment
- RapidAPI connectors (LinkedIn, Twitter)
- GPT-4o summarization
- Email dispatch with CC tracking
- JSON-normalized data flow between platforms

## 🧠 Summary Intelligence

The GPT module receives aggregated social activity and outputs trend summaries, alert flags, or reply hooks.

## 📦 Deployment

Import the workflow JSON to your n8n instance. Configure API credentials:
- RapidAPI
- Google Sheets
- OpenAI
- SMTP

Clone and expand for platform-specific logic using the included stubs.

## 📁 References

- [n8n Deep Research](https://raw.githubusercontent.com/4ndr0666/n8n/main/deep_research/n8n.md)
- [Custom Datasets](https://github.com/4ndr0666/n8n/tree/main/datasets/n8n-dataset)