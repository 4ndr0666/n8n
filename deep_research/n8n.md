Excellent. I’ll perform a deep recursive analysis of the official n8n documentation, focusing on OSINT-specific usage, cloud-based operation, and advanced automation with JavaScript, OpenAI, and Shodan integrations.

I’ll return with a distilled, tactical “n8n for Dummies (Black Hat OSINT Edition)” field manual that provides real workflows, setup steps, and practical attack surface applications. Please standby while I gather and synthesize the information.


# n8n for Dummies (Black Hat OSINT Edition)

## What is n8n and Why Use it for OSINT?

n8n is a powerful **workflow automation platform** that lets you connect apps and services to automate tasks. It combines the flexibility of code with the speed of a no-code interface. In practice, this means you can visually design complex workflows and also inject custom code where needed. For an Open-Source Intelligence (OSINT) practitioner (even a “black hat”), n8n serves as an automation engine to orchestrate reconnaissance tasks across multiple data sources. With over 400 integrations and native AI capabilities, n8n can interact with APIs like Shodan and OpenAI, scrape or transform data, and trigger actions – all **without manual repetition**. This makes it ideal for automating OSINT workflows such as network scanning, data enrichment, and generating intelligence reports.

**Why use n8n for OSINT?** OSINT often involves pulling data from many open sources (APIs, websites, databases), parsing and correlating that data, and then taking some action or generating a report. n8n provides a **visual canvas** to build these pipelines step-by-step. You can chain together API calls, processing logic, and outputs (alerts, files, etc.) in one continuous flow. Importantly, n8n allows **advanced scripting** via a Code node (formerly “Function” node) for custom JavaScript/Python when the built-in nodes don’t cover your needs. In an OSINT context – especially a “black hat” style one – this means you can automate tedious or large-scale data gathering tasks that would be impractical to do by hand. For example, you might schedule n8n to regularly query Shodan for new devices, use custom code to filter interesting results, and then feed those into an AI for analysis or alerting. All of this can run unattended, giving you a “digital sidekick” for intelligence gathering.

Finally, n8n is **flexible in deployment**. You can self-host it (keeping data on your own servers), or use **n8n Cloud**, the hosted offering, which requires no installation or maintenance. In this guide we’ll assume you’re using **n8n Cloud** for convenience. (Using Cloud means n8n is ready to go in your browser with no setup, though note that on Cloud you cannot install additional npm packages in code nodes – more on this later.) With the basics introduced, let’s get your n8n Cloud account set up and walk through the interface.

## Quick Start: Setting Up n8n Cloud and the Basics

**Sign Up and Initial Setup:** To start using n8n Cloud, first sign up for an account. n8n Cloud offers a free trial for new users. Simply visit the n8n website and create an account – you’ll get an instance of n8n running in the cloud. Once logged in, you can access the **Editor UI** which is where you build and run workflows. No installation is needed; everything runs in your browser.

**Navigating the Editor UI:** The n8n Editor interface has a few key parts to understand before building your first workflow:

&#x20;*The n8n Cloud Editor UI, showing the left-side panel with main sections.*

* **Left-Side Panel:** This is a sidebar containing core sections for managing workflows and resources. Here you can create or access your **Workflows**, set up **Credentials** (for connecting to external services), browse **Templates** (pre-built workflows), view **All Executions** (logs of workflow runs), and more. In n8n Cloud, you’ll also see an **Admin Panel** for usage/billing, since Cloud is a managed service. You can collapse or expand this sidebar via the small arrow. The **Workflows** section is where you’ll create and organize your automation workflows (think of a workflow as a visual script). The **Credentials** section is very important for OSINT: here you securely store API keys and connection info for services like Shodan or OpenAI so that nodes can use them without hardcoding secrets. The **Templates** library provides example workflows you can import with one click – a great way to jumpstart common automations.

* **Top Bar:** At the top of the editor, you have controls and info about the current workflow. On the left, you can give your workflow a name (by default it might be "My Workflow") and optionally add tags to categorize it. In the middle, there is a toggle to activate/deactivate the workflow (when active, triggers like schedules or webhooks will run it). Usually, you’ll build and test with it **Inactive**, and only activate when you’re ready for it to run automatically. On the right side, you’ll find the **Save** button (to save changes) and a **Run** button (labeled “Test Workflow” when editing). There’s also a **Share** button (for inviting collaborators on paid plans) and a **History** drop-down where you can see previous versions if you saved multiple times. For now, note the **Test Workflow** (execute) and **Save** buttons – you’ll use those frequently while building.

&#x20;*The blank canvas where you build a workflow. The “+” button at top right opens the nodes menu to add new nodes.*

* **Canvas:** The large grid area is the workflow canvas. This is where you will place nodes and connect them to design your automation. When you start a new workflow, you’ll see a dotted grid background with a prompt to “Add first step…”. You can add nodes by clicking the **+** button (usually hovering at the top-right or in the center “Add first step” box) which opens the nodes panel (a list of all available integration nodes). You can also drag nodes from the panel onto the canvas. The canvas supports zooming and panning (use the buttons at the bottom or mouse controls) to navigate large workflows. You can also add **Sticky Notes** for documentation (via the note icon near the + button) to leave yourself comments about what a part of the workflow does. Once you add at least one node, the “Test workflow” button will become enabled on the canvas, allowing you to execute the workflow manually for testing. Don’t worry about execution details yet; we’ll walk through building and running a specific OSINT workflow soon.

**Basic Concepts:** n8n workflows are made up of **nodes** connected in sequence. Each **node** performs a single step (e.g., an API call, a data transformation, an IF condition, sending an email, executing code, etc.). Data flows from one node to the next through these connections. Some nodes are triggers that start workflows (like a Cron trigger or Webhook trigger), while others are regular action/transform nodes that run in order. Nodes pass **JSON data** between each other – for example, one node might output a list of IP addresses as JSON, and the next node will receive that list as input. Understanding the data structure is key: n8n represents data as an array of items, each item containing a JSON object (and optionally binary data). In most cases, you don’t have to wrap or manage arrays manually; n8n will handle feeding each item to the next node automatically. For instance, if one node outputs 5 items, the next node will execute 5 times (once per item) by default. This means if you have a list of targets, you can feed them into an HTTP Request node and it will call the API for each target item automatically – very handy for looping through results without writing code.

Before diving into a full example, let’s summarize the key building blocks we will use for OSINT workflows in n8n Cloud:

* **Trigger Nodes:** These start the workflow. Common triggers include the **Schedule Trigger** (to run workflows on a schedule, like Cron jobs) and the **Webhook** (to start when an HTTP request is received). For black-hat OSINT, a Schedule Trigger is useful to run periodic scans. You can configure easy intervals (every X minutes/hours, daily, weekly, etc.) or use a custom Cron expression for precise timing. For example, `0 5 * * 1` as a Cron expression would run every Monday at 5:00 AM. n8n even suggests using tools like Crontab Guru to generate Cron strings.

* **HTTP Request Node:** The HTTP Request node is your Swiss-army knife for calling external APIs. Since many OSINT sources expose REST APIs (e.g., Shodan, VirusTotal, etc.), this node lets you query any URL with GET/POST and so on. It’s extremely versatile – essentially acting as a custom API client inside your workflow. As the docs say, *“The HTTP Request node allows you to make HTTP requests to query data from any app or service with a REST API.”*. You can set the URL, method, headers, query parameters, body, and authentication as needed. We’ll use this node to call Shodan’s API and others. Tip: n8n provides a feature to **import a cURL command** into an HTTP node, which is useful if you already have an API call working in curl – you can paste it and n8n will configure the node for you.

* **Integration Nodes (App-Specific Nodes):** n8n also has many built-in nodes for specific services. For example, there is an **OpenAI node** that directly integrates with OpenAI’s API (so you don’t have to manually craft HTTP calls for GPT). There’s also a node for TheHive (a security incident management platform), which we’ll mention later for sending alerts. If n8n has a dedicated node for a service you need, prefer using it as it simplifies authentication and operations. In our case, we’ll primarily use the OpenAI node for AI tasks. (Shodan does not have a dedicated node, so we’ll use HTTP Request for it.)

* **Function (Code) Node:** This node (now simply called the “Code” node in n8n) lets you write custom JavaScript (or Python) to manipulate data in ways that might be too complex for the built-in nodes. For instance, you can use it to loop through data in custom ways, apply complex logic, or format output exactly as needed. The Code node replaces the older Function node from n8n < v0.198.0. We will use JavaScript in this guide (note that Python is also supported via Pyodide, but it runs slower and has limited libraries). JavaScript in n8n runs in a Node.js environment, and you can use modern JS features and even promises for async operations. However, in n8n **Cloud**, you cannot import arbitrary npm packages for security reasons – you are limited to built-in modules (`crypto` and `moment` are provided for convenience on Cloud). The Code node is extremely powerful for OSINT workflows because you might need to parse custom data, do calculations (e.g., convert an IP integer to dotted format, or parse a HTML response), or make decisions that the stock nodes don’t cover. We’ll give scripting tips later in this manual.

* **Other Useful Nodes:** Depending on your workflow, nodes like **IF** (for conditional filtering of items), **Merge** (to recombine branches), **Set** or **Edit Fields** (to select or rename fields in your data), **Spreadsheet File** (to read/write CSV or Excel), **HTML Extract** (to parse HTML content), etc., can come in handy. For example, an IF node can act as a filter to drop items that don’t meet a condition (we’ll use one to filter ports). The Set node can be used to pick specific JSON fields from a response (similar to how a SELECT works in databases) – useful to trim down the data from an API to just what you need.

* **Credentials:** n8n uses Credentials to store secrets (API keys, tokens, passwords) securely and reuse them. For any external service that requires authentication (OpenAI, Shodan, etc.), you should set up a Credential in n8n rather than embedding keys in your node parameters. n8n has predefined credential types for many services (e.g., an “OpenAI API” credential type) which simplifies configuration. If a service isn’t listed (Shodan might not have a predefined one), you can use a **Generic Credential** approach, like using HTTP Basic Auth, Bearer tokens, or query params. For Shodan, for instance, the simplest method is to include your API key as a query parameter in the URL (Shodan’s API uses `?key=YOUR_KEY`). Alternatively, you could set it up as a generic “Query Auth” credential in n8n’s HTTP node credentials so that it’s inserted automatically. We’ll note how to handle it in the example. The key point: set up your API keys in Credentials once, then reference that credential in your nodes – it keeps your workflows clean and secure.

With the fundamentals covered, let’s build a concrete example: an automated Shodan scan workflow, step by step.

## Step-by-Step Example: Automated Shodan Scanning and Alerting

One classic OSINT task is scanning for open ports or devices using Shodan (the “search engine for internet-connected devices”). In this example, we’ll create a workflow that periodically checks a list of target IP addresses on Shodan and alerts us if unexpected ports are found (as an indicator of something new or potentially interesting on those hosts). This example will demonstrate scheduling, making API calls, looping through results, filtering data, and sending an alert. It’s inspired by a real-world SecOps use case (monitoring your own network for rogue services), but as a black-hat OSINT operator you might use it to keep an eye on someone else’s assets (ethically questionable – but here we focus on *how* it can be done). **Note:** Ensure you have a Shodan API key for this; you can get one by registering on Shodan’s website.

**Workflow Outline:** Every week, retrieve a list of IPs and expected open ports. For each IP, query Shodan for its open ports. Compare the actual open ports to the expected ones; if any unexpected ports are open, compile those details and send an alert (for example, create a report or an incident in a system like TheHive or simply send an email). We’ll walk through each part:

1. **Trigger on a Schedule:** Add a **Schedule Trigger** node to kick off the workflow. In n8n, search for “Schedule” in the nodes panel and drag out the **Schedule Trigger**. Configure it to run at your desired interval. For weekly scans, you might set it to Every 1 week, on Monday at 05:00 (5 AM). This uses n8n’s built-in UI for intervals, or you can switch to Cron mode and enter a cron expression (`0 5 * * 1` for Monday 5:00). Once active, this node ensures the workflow runs automatically at that time. (During testing, you can also manually trigger the workflow with the Test button, bypassing the schedule.)

2. **Fetch Target List (IPs and Expected Ports):** We need a list of IP addresses to monitor, each with the ports we expect to be open on them (so we can detect anomalies). There are a few ways to supply this data:

   * For simplicity, you could use a static list via a **Function** or **Set** node – i.e., just hardcode an array of IPs and their expected ports.
   * For a more dynamic approach (perhaps the list is maintained elsewhere), you could use an HTTP Request node to fetch the list from an external source (maybe a gist, a Pastebin, or an internal API). In our scenario, suppose we maintain a JSON file or endpoint that returns something like: `[{ "ip": "192.0.2.1", "expected_ports": [80,443] }, {...}]`. We can call that to get the latest list each time.

   In the referenced n8n template, they did exactly this: *“fetching a list of watched IP addresses and expected ports through an HTTP request”*. So, add an **HTTP Request** node connected after the trigger, set it to GET, and use the URL where your IP list is stored. If it’s static, you could skip this and embed the list in the workflow, but using an external list makes it easier to update targets without editing the workflow. Ensure this node’s output is the list of IPs (each IP as one item in JSON). For example, the node might output an array of items like:

   ```json
   [
     { "json": { "ip": "192.0.2.1", "expected": [80,443] } },
     { "json": { "ip": "192.0.2.50", "expected": [22] } },
     ...
   ]
   ```

   Each item will feed into the next node.

3. **Loop Through Each IP – Shodan Lookup:** Now, for each IP from the list, we want to query Shodan. In n8n, as noted, if you pass multiple items to an HTTP node, it will execute for each item automatically. We can leverage that. Add another **HTTP Request** node and connect it to the output of the previous step (the IP list). This will automatically iterate over the items. Configure this HTTP node to call the **Shodan REST API** for host information. The Shodan API endpoint to get open ports and details for an IP is:
   `https://api.shodan.io/shodan/host/{IP}?key=YOUR_API_KEY`
   We will replace `{IP}` with the actual IP from our input, and `YOUR_API_KEY` with our Shodan key (we’ll use credentials for this). In the HTTP node:

   * Set **Method**: GET.
   * Set **URL**: you can type it with an expression for the IP. For example:

     ```
     https://api.shodan.io/shodan/host/{{$json["ip"]}}?key={{ $credentials("ShodanApi").apiKey }}
     ```

     Here, `$json["ip"]` will insert the IP from the input item (each item’s JSON has an “ip” field if our earlier step is structured as above). For the API key, if you created a Credential (say of type HTTP Request with Query Auth or a custom credential named “ShodanApi”), you can reference it in an expression as shown. Alternatively, simpler: put the API key directly in the URL query for now (or use the **Authentication** section to set it as query parameter via credentials). Using credentials is recommended so you don’t expose the key in plain text in your workflow. (Note: If you use the HTTP Request node’s built-in **Credentials** feature, you might configure it as “Query Auth” where you specify a key name and value in the credential settings – then you can just provide the base URL here and n8n will attach `?key=...` automatically.)
   * No body or special headers needed for this GET. Just ensure the URL is correct and authentication is set.

   This node will call Shodan for each IP. The result from Shodan for each IP will be a JSON with various fields. According to Shodan’s docs, the response includes things like `ports` (a list of port numbers), `data` (an array of port details/banners), `hostnames`, etc. The n8n template description states: *“It begins by fetching ... Each IP address is then processed... For every IP, the workflow sends a GET request to Shodan... to gather detailed information. It then extracts the data field from Shodan's response, converting it into an array. This array contains information on all ports Shodan has data for regarding the IP.”*. In our workflow, the HTTP node’s output for each IP will be that Shodan JSON. We may have to extract the list of open ports from it.

   One approach is to use an **Item Lists** node or a **Code** node to expand the Shodan result. For example, the Shodan JSON has a `"data"` array (each element of which might correspond to an open port with details). We could take that array and split it so each port becomes its own item to easily filter. If using an Item Lists node (there’s an operation “Split Out Items” which can take an array field and output one item per element), we’d configure it to split out the `data` array. Alternatively, we can use a Code node to do something like:

   ```js
   const portsData = $json.data || [];
   return portsData.map(portEntry => {
     return { json: { 
         ip: $json.ip, 
         port: portEntry.port, 
         expectedPorts: $json.expected, 
         details: portEntry 
     } };
   });
   ```

   This would transform one item (one IP’s Shodan result) into multiple items – one per open port on that IP. Either way, the goal is to have individual port items to filter next.

4. **Filter Unexpected Ports:** Now that we have the data on actual open ports per IP, we compare against the expected ports list. Add an **IF** node (or a **Filter** function) to drop any ports that are expected. In n8n’s IF node, you can set a condition. Our item has (if we followed the code above) `port` and `expectedPorts` fields. We want to keep items where `port` is **not** in `expectedPorts`. Since the IF node UI might not directly support “contains in array” logic easily, another approach is using a Code node to filter. But let’s assume we try IF:

   * IF node can have two outputs: true (condition met) and false (condition not met). We could configure: **Condition:** “Number: *port* is not equal to (any of) expectedPorts”. However, `expectedPorts` is an array. We might have to use an expression: something like `{{$json["expectedPorts"].indexOf($json["port"]) === -1}}` as a boolean expression in the IF node.
   * Alternatively, easier: use a Code node after splitting ports: in code, do `if (!item.json.expectedPorts.includes(item.json.port)) return item;` to only return unexpected ones.

   The official template did: *“A filter node compares the ports returned from Shodan with the expected list obtained initially. If a port doesn't match the expected list, it is retained for further processing; otherwise, it's filtered out.”*. We replicate that logic. After this step, we have only the “unexpected open ports” for each IP (if any). If an IP’s open ports all matched the expected list, none of its ports will pass the filter, meaning that IP effectively gets no alert.

5. **Compile Alert Data:** For each unexpected port that remains, we prepare the data we want to include in an alert or report. We likely have fields like:

   * IP address
   * Port number
   * Perhaps the service or banner (Shodan’s `data` entries often include a `product` or banner text, and possibly an `ssl` object for HTTPS, etc.)
   * Hostnames associated with the IP (Shodan might return an array of hostnames for that IP in the `hostnames` field or within each data entry).
   * Any other info (e.g., Shodan data might include the `timestamp` of when it was scanned, or specific protocol info).

   We can use a **Function/Code node** or **Set node** to shape this information. For example, using a Set node, we could map:

   * “IP” = `{{$json["ip"]}}`
   * “Port” = `{{$json["port"]}}`
   * “Service” = `{{$json["details"]["_shodan.module"]}}` (Shodan returns a module name or product name; this depends on Shodan’s data)
   * “Banner/Summary” = maybe `{{$json["details"]["data"]}}` (which might be the raw banner text).
   * etc.

   The goal is to have a nicely formatted piece of text or structured data describing why this port is noteworthy. In the example template, they formatted it into an HTML table and then converted to Markdown:
   *“This collected data is then formatted into an HTML table, which is subsequently converted into Markdown format.”*. You can choose your format. For a simple approach, you might generate a Markdown string in a Code node, or use the **HTML node** (to create a table) followed by a **Markdown** node (if such exists) or just keep it HTML for email.

6. **Send an Alert or Report:** Finally, deliver the results. There are various ways to output the findings:

   * **TheHive Alert:** If you’re using TheHive for case management, n8n has TheHive nodes that can create alerts or cases. In the template, they used a TheHive node to create an alert with a bunch of fields (title, description, severity, tags, etc.). The alert contained the table of unexpected ports and metadata like TLP (Traffic Light Protocol) markings.
   * **Email or Messaging:** You could use an **Email node** to send yourself an email with the list of unexpected ports. Or a **Slack node** (if you have a Slack webhook or bot token) to send a message to a Slack channel. For a black-hat operator, maybe an encrypted email to yourself or a private Matrix/Discord message could work to notify you without raising suspicion.
   * **Write to File or Database:** If you just want to log it, you might append the results to a Google Sheet, or save in a CSV file on an SFTP, etc. n8n has nodes for many storage options.

   Let’s say we choose to send an alert to a chat for simplicity. Add a Slack node (or Discord, etc.) after the compilation step. Format a message like: `"⚠️ Shodan Alert: Unexpected port {{ $json["Port"] }} open on {{ $json["IP"] }} (Service: {{$json["Service"]}})"` plus maybe details. If you built a Markdown table of all findings, you can just send that whole text.

   If you use TheHive, configure the **TheHive Create Alert** node with the fields. For example:

   * Title: `"Unexpected open ports on {{ $json["ip"] }}"` (with the IP).
   * Description: the markdown table (from previous node’s output).
   * Severity: Medium (or however you classify).
   * Tags: e.g. \["Shodan","OSINT"].
   * TLP: Amber (as in template).
   * etc.
     This will create an alert in TheHive for your team to review.

Now the workflow is complete. To recap in a concise form:

* **Schedule Trigger** (e.g. every Monday 5:00) -> **HTTP Request (get IP list)** -> **HTTP Request (Shodan lookup)** -> **(Split ports if needed)** -> **IF node (filter unexpected ports)** -> **Set/Function (prepare alert data)** -> **Alert (Slack/Email/TheHive)**.

When you run this workflow, say it finds on 192.0.2.50 that you expected only port 22, but Shodan now sees 22 *and* 8080 open. The IF node will let port 8080 through. The final alert might say: “Unexpected port 8080 open on 192.0.2.50 – Service: Apache httpd, Banner: ...” etc. If everything matches expected, the workflow will end up with no alert (you could configure it to send a “all clear” message or simply do nothing in that case).

This example shows how **n8n can automate passive reconnaissance**: you never actively scanned the IPs yourself; you leveraged Shodan’s existing data (passive from your perspective) and just processed it. The workflow runs in cloud, so you could essentially “set and forget” this, receiving weekly intel automatically.

*(For reference, a similar workflow is described in an official template: it looped through IPs, queried Shodan for each, filtered ports, and created a TheHive alert. We implemented the same logic here in a custom manner.)*

## Integrating OpenAI (GPT-4) for Data Analysis and Red Teaming

One of the standout features of n8n is its native integration with AI models, including OpenAI’s GPT series. This can be a game-changer for OSINT automation: you can incorporate an AI “analyst” into your workflows. In practical terms, the **OpenAI node** allows you to send prompts to OpenAI’s API and get responses, which you can then use in your workflow. This could be used for summarizing data, extracting entities, translating text, or even generating hypotheses or attack ideas (i.e., a form of red-team brainstorming). Let’s discuss how to set this up and some patterns:

**OpenAI Credentials:** First, obtain an API key from OpenAI (you’ll need an OpenAI account with access to their API). In n8n, configure an **OpenAI credential** (available under Credentials -> Create -> OpenAI). You just need to plug in the API key here. Once that’s saved, you can use the **OpenAI node** in your workflows.

**Using the OpenAI Node:** The OpenAI integration in n8n supports various operations (completions, chat, edits, etc., depending on API). If you’re using GPT-4 or GPT-3.5, you’ll likely use the **Chat model** operation. The OpenAI node expects a prompt (or a conversation) and returns the AI’s response. For example, suppose after querying Shodan, you have a bunch of banners or device data that you don’t fully understand. You could add an OpenAI node to **interpret that data**.

Example – *Data Classification:* Imagine you retrieved some text or metadata about a device (say a server’s SSH banner or an IoT device’s metadata). You want to know if this device might be vulnerable or interesting. You can feed the banner text to OpenAI with a prompt like: *"You are a cyber security expert. I have this banner from an IoT device: '{{banner\_text}}'. Identify what software or service it is and any known vulnerabilities or CVEs associated with it."* The OpenAI node will return a textual answer. You can then parse that or directly include it in your report. In a workflow, you might do: Shodan -> OpenAI -> output.

Another example – *Prompt Chaining:* Prompt chaining means using multiple AI calls in sequence, where each step’s output informs the next prompt. In n8n, you can chain OpenAI nodes by simply connecting them sequentially and using the previous node’s output in the next node’s prompt. For instance:

1. First OpenAI node: Prompt = *"List the open ports and services in the following data, and identify any that seem unusual: {{JSON\_from\_Shodan}}".* This could produce a summary.
2. Second OpenAI node: Prompt = *"Given the unusual ports you identified ('{{answer from first node}}'), explain what risks they might pose or what an adversary could do with them."* This yields a risk analysis.
3. Third OpenAI node (optional): *"Draft a brief report in markdown summarizing these findings for a technical audience."* – The AI might output a nicely formatted summary.

This is a simple form of creating an **AI chain**. n8n also has specialized “Chain” nodes under the AI category (like a Question-Answer Chain, etc.), which are part of its LangChain integration. But you can achieve a custom chain with basic nodes as above. Keep in mind that AI chains in n8n do not have persistent memory by default. That means each OpenAI node doesn’t automatically remember earlier conversation unless you explicitly feed the context in. To maintain context, you could accumulate a conversation in a variable or use an **AI Agent** node (which does have memory options, if using GPT-4 with functions). For advanced use, n8n’s **OpenAI Functions Agent** node can let the AI decide to call tools (nodes) and iterate, but that’s beyond a beginner scope.

**Adversarial Red Teaming:** The user specifically asked about adversarial red teaming with OpenAI. This can mean using the AI to simulate an attacker or to test the AI with tricky prompts. Within n8n, you might use OpenAI to **generate attack ideas or social engineering content** based on OSINT data. For example, if you have a bunch of leaked emails or personal info from OSINT, you could ask OpenAI to draft a phishing email that might trick a person given that info (careful: this treads into ethically dubious territory and OpenAI might refuse if it detects disallowed content). Another use: given an organization’s public footprint (e.g., technologies used, possible misconfigurations), ask the AI to **brainstorm possible ways to breach the organization**. This is like having an AI red-team assistant. Always ensure you’re following OpenAI’s usage policies; avoid asking the AI to do anything outright malicious or disallowed. But strategic brainstorming is usually fine if worded responsibly.

**Data Classification and Triage:** OpenAI can sift through large text data to find what’s important. If your OSINT workflow gathers a huge amount of data (say hundreds of device banners or a full WHOIS record or a pastebin dump), you can use OpenAI to extract key points. For example, *"Extract all email addresses and domains from the following text..."* or *"Summarize this 5-page WHOIS record briefly."* This can save you time in analysis.

**Using AI in the Workflow:** Let’s incorporate a quick sub-example. Imagine after the Shodan step, you want an AI opinion on the results:

* Add the OpenAI node after the Filter (unexpected ports) step. Set it to “Completion” or “Chat” with GPT-4.
* Prompt: *"You are an AI assistant that analyzes network scan results. I have the following open ports that were not expected: {{JSON.stringify(\$node\["Filter"].json)}}. Explain what services these might be and if they might be security concerns."*
* The node will output a response text. You can then use a Set node to attach that text to your alert message (like include the AI’s summary in the Slack message or TheHive alert description).

By doing this, you augment the raw data with analysis. In effect, you’ve automated not just data collection but a piece of the reasoning as well. This is especially useful if you’re monitoring a lot of data and want the boring stuff (like reading banners and comparing with CVE lists) to be handled automatically.

**Tip:** The OpenAI node can be a bit slow (depending on model and token size). If using a large context (long prompts/responses), consider that it might add several seconds to your workflow. Also, handle errors (in case the API fails or content is disallowed, the node might throw an error – you can catch and handle that using n8n’s error handling or a Try/Catch logic in workflows).

In summary, integrating OpenAI in OSINT workflows allows for a form of intelligent automation: you gather data with other nodes, then let the AI interpret or enhance that data, then proceed with the workflow (perhaps branching based on the AI’s answer or just appending the analysis to reports). As you grow more comfortable, you can explore n8n’s AI-specific nodes like **Agents** and **Chains** which provide more structured ways to use AI in workflows (e.g., tools usage, vector database queries for OSINT corpuses, etc.), but those require a deeper dive into LangChain concepts.

## Additional OSINT Workflow Ideas and Templates

The Shodan example is just one of many possibilities. Here are a few more **real-world OSINT automation patterns** you might implement with n8n:

* **Threat Intel Enrichment Pipeline:** Suppose you obtain an Indicator of Compromise (IOC) such as an IP address, domain, or file hash (maybe from a feed or another tool). You can build a workflow to enrich this IOC with data from multiple sources. For instance, for a given IP: do a Shodan lookup (open ports), a VirusTotal IP report (malicious score, related domains) using VirusTotal’s API, a WHOIS lookup (registrant info), and a geolocation API (to get country/ISP). Each of these can be done via HTTP Request nodes (VirusTotal has an API and even a predefined credential in n8n). After gathering the data, aggregate the findings (maybe using a Code node or simply collating text), and then output an intelligence report. This could be triggered by a Webhook (so whenever you input an IP via an HTTP request, n8n returns the enriched data) or run on a list of IOCs regularly. The key benefit is consistency – every IOC is investigated in the same, thorough way without manual effort. You can include OpenAI here as well – for example, ask it to summarize the threat level of the IOC based on the combined data.

* **Data Harvesting & Monitoring:** n8n can periodically pull data from websites or APIs to look for new information. For example, you could monitor Pastebin or GitHub gists for certain keywords (though be mindful of API limits and terms). Or use the Twitter (X) node to track certain hashtags or users for intel. Or use RSS Feed node to gather news articles related to cybersecurity. A concrete idea: monitor a vendor’s security bulletin page for new vulnerabilities (HTTP Request to fetch the page HTML, the HTML Extract node to parse the relevant section, then if a new bulletin is found compared to last run, send yourself an alert). This borders on web scraping, which n8n can do in simple cases with the HTML extract or through third-party APIs.

* **Credential Stuffing/Pwned Passwords Check:** As a black-hat leaning OSINT, you might collect leaked credentials. You can automate checking if any known password dumps contain a specific password (using the HaveIBeenPwned API for passwords or similar). N8n could take a list of passwords and query the HIBP API for each (they have an anonymized range query). Or check if an email appears in breaches (HIBP has an API for breached accounts). This helps in assessing the exposure of certain accounts.

* **Reconnaissance on Domain Infrastructure:** Given a domain, you could automate retrieval of DNS records (n8n has a DNS node), subdomains (using an API like SecurityTrails or CRT.sh via HTTP), and then feed each discovered host into Shodan for port scans. This becomes a full recon pipeline: domain -> find subdomains -> resolve to IPs -> Shodan lookup -> aggregate results. You might output this as a spreadsheet or report listing all found systems and services.

For many of these tasks, you don’t have to start from scratch. **n8n’s Template library** (accessible via the Templates section in the left panel) contains community-contributed workflows. There is a category for security/SecOps. For example, the “Weekly Shodan Query – Report Accidents” workflow we emulated is available there (you can find it by searching “Shodan” in templates and import it directly). Importing a template will load the workflow into your n8n canvas, which you can then inspect and customize. This is a great way to learn how others build their automations. Some useful templates or examples to look for:

* Shodan monitoring workflows (like the one we did).
* VirusTotal file scan workflows.
* Dark web monitoring (if any exist).
* General “Security Operations” templates (n8n had an initiative to provide SecOps/ITOps templates).

When using templates, always check the nodes to update credentials (the template will have placeholder credentials you need to replace with your own API keys), and adjust any hardcoded values (like target IPs or search queries) to fit your needs.

## Tips and Best Practices for Scripting and Automation

To wrap up this manual, here are some important tips and best practices when using n8n for OSINT, especially if you’re pushing the platform in advanced ways (scripting, lots of API calls, etc.):

* **Use Credentials for API Keys:** This was mentioned earlier but cannot be stressed enough. It keeps your workflows secure and portable. For any HTTP Request node, instead of putting the API key in the URL or header directly, use the **Authentication** options. n8n supports many auth types: Basic, OAuth2, Header Auth, Query Auth, etc.. For example, for Shodan you could choose “Query Auth” and set the key name to `key` and key value in the credential. For OpenAI, use the built-in OpenAI credential (it sets the Authorization Bearer header). This way, if you share the workflow or move it, the keys aren’t revealed in the JSON export (they are stored encrypted separately).

* **Testing and Debugging:** Build your workflow incrementally and test as you go. n8n allows you to manually execute a workflow (or even just selected nodes). Use the **“Test Workflow”** button often while designing – it will run with the current configuration and you can inspect each node’s output in the Execution view. If something isn’t working, n8n’s execution log will show errors. You can also add a **Debug** or **Function** node with `console.log` statements (they will print to the browser console or execution log) to troubleshoot data issues. Another tip: use the **NoOp** node (basically does nothing but passes data) as a placeholder output to inspect data at certain points.

* **Code Node Practices:** When writing JavaScript in the Code node, remember a few things:

  * The Code node expects you to return an array of items (or a single item array). Each item should be an object like `{ json: {...} }`. However, n8n now auto-wraps outputs that aren’t arrays or missing `json` in many cases. Still, it’s good practice to return `items` or an array explicitly. Typically, you’ll see code node boilerplate like:

    ```js
    // items is an array of input items
    const results = [];
    for (const item of items) {
      // process item.json
      results.push({ json: { /* new data */ } });
    }
    return results;
    ```

    If you choose “Run Once for All Items” mode, you’ll be dealing with `items` array at once (useful when combining data). If “Run Once for Each Item”, you handle `item` one by one and return one item.
  * You **cannot make HTTP requests or access the filesystem directly inside Code nodes**. So if you think “I’ll just use `fetch()` or an npm library to call this API in code”, n8n won’t allow it (for security and architecture reasons). Always use the HTTP Request node for external calls, even if that means splitting your logic into multiple nodes. The Code node is best for processing data, not fetching new data.
  * Performance: since Cloud doesn’t allow external libraries, you are limited to native JS. That’s usually fine for most data manipulation (you have all of ES2020+ features). If you absolutely need an external library (say for parsing a specific file format), you’d have to self-host n8n and enable that feature, but for OSINT tasks it’s rarely necessary.
  * The Code node provides some **built-in shortcuts** like `$json` (current item’s JSON), `$node` (to access data from other nodes), etc. In fact, those are more commonly used in **Expression editor**, but they work in code as well. You can see available variables by typing `$` in the code editor or referring to the docs.
  * If your code becomes very complex, consider if you can break the task into smaller nodes or use a different approach. Sometimes using multiple simpler nodes (e.g., a combination of Set and IF) can be easier to maintain than one big blob of code.

* **Expression Editor:** n8n allows you to use expressions (small pieces of code enclosed in `{{ }}`) in almost any field of a node. This is extremely useful to dynamically insert values. For example, we used `{{$json["ip"]}}` to insert the IP from the previous node. Learning the basics of n8n expressions will save you from writing unnecessary code nodes. You can reference other nodes by name: e.g., `{{$node["Shodan Lookup"].json["data"][0]["port"]}}` would get the first port from the Shodan lookup node. Expressions use the same context as code nodes (with `$node`, `$json`, etc.). In the UI, n8n provides an expression editor with auto-complete to help build these. The quickstart example in the docs shows using expressions to create a message – in our context, you might use an expression to compose an alert text using values from multiple nodes.

* **Avoid Hardcoding, Use Variables:** If you find yourself reusing a specific value (like the same API URL or an ID) in multiple places, consider using the **Environment Variables** feature or a single source of truth. n8n allows some config via environment (mostly for self-hosted) and also has a concept of Workflow Static Data. For a simpler approach, you might store config in a Code node (run once) or the first Set node and reference it later. This way, you change it in one spot if needed. For example, store your target domain or search keyword in one place and reference that variable across nodes.

* **Handling Errors and Timeouts:** OSINT workflows can run into flaky sources or rate limits. You can mark the HTTP node to **“Continue On Fail”** (so one failed API call doesn’t stop the whole workflow – you can later handle the error path) in its settings. Or use a Try/Catch logic with the Error Trigger node to capture failures. Also, consider adding a small delay if you’re hitting many API calls quickly (n8n has a **Wait** node which can pause for specified seconds, or use the **Queue** or **Batch** mechanism to throttle calls). Shodan’s free API, for instance, might have a rate limit – you don’t want to blast it with hundreds of simultaneous requests. By default, n8n processes one item at a time through an HTTP node (not parallel), which helps avoid hitting rate limits too fast.

* **Stay Within API Terms:** As a “black hat” OSINT user, you might be tempted to do massive data scraping. Keep in mind that using n8n Cloud means your workflows’ traffic is going through n8n’s cloud IPs. If you abuse an API, that could lead to blocking of those IPs or your account. Also, some OSINT tasks may violate terms of service of certain platforms if done at scale. Use the power responsibly and legally. n8n itself doesn’t impose strict limits, but external services might. It’s often a good idea to integrate an **API key usage check** – e.g., the Shodan API provides a method to get your query credits usage. You could call that and alert if you’re near a limit.

* **Leverage the Community:** The n8n community forum and documentation often have examples of specific use cases. If you’re trying something unusual (like decoding an encrypted value, or dealing with a tricky pagination API), chances are someone on the forum has tackled it. For example, searching the forums for “Shodan Auth” yields a discussion on how to auth to Shodan’s API in n8n (which might just confirm using the key in URL as we did). The community is active and can provide workflow samples or nodes if you get stuck.

* **Security Considerations:** If you handle sensitive data (even as a black hat, you might collect data you don’t want to leak), be mindful of where that data goes. n8n Cloud is secure, but storing results in third-party services (Google Sheets, etc.) might expose them. Also, if you’re logging into n8n from a home connection while doing potentially illegal recon (not condoning it), remember there could be a trail. In short, opsec is on you – n8n is a tool, how you use it and cover your tracks (or not) is beyond its scope. Technically, n8n can integrate with privacy tools too (maybe call Tor APIs or use proxies, though that’s advanced and not in official docs).

* **Maintaining Workflows:** Over time, you might accumulate many workflows for different OSINT purposes. Use naming conventions and **tags** (the top bar “Add tag” feature) to organize them (e.g., tag workflows with “OSINT”, “Recon”, “Enrichment” etc.). n8n allows you to disable workflows you’re not using to avoid clutter in the execution list. Also, document your workflow with a few **Sticky notes** on the canvas explaining what it does – six months later you might forget details.

By following these practices, you’ll make your n8n experience smoother and your automations more robust.

## Conclusion

In this guide, we covered how n8n can be harnessed as a “tactical automation tool” for black-hat style OSINT workflows. You’ve seen how to set up n8n Cloud and navigate its interface, and how to build a workflow that automates a Shodan scan and alert. We discussed integrating OpenAI’s AI capabilities to add a layer of analysis or creative thinking to your data, and explored other OSINT automation ideas from threat intelligence enrichment to passive recon. With n8n, tasks that used to require running multiple scripts and manual data wrangling can be orchestrated in one coherent system – and you maintain full control over the logic.

As you build more complex workflows, you’ll likely mix and match many of the techniques described: scheduled triggers, HTTP calls to various APIs (Shodan, VirusTotal, WHOIS, etc.), custom JavaScript for parsing, AI for summarization, and output to your preferred alerting channel. The possibilities are endless, limited only by the APIs available and your creativity. And thanks to n8n’s visual approach, you don’t have to be a professional developer to implement these – though having some coding/scripting knowledge, as we applied with the Code node and expressions, certainly helps unlock the advanced use cases.

Remember to refer to the official n8n documentation for specific nodes and troubleshooting (we’ve cited many relevant portions throughout). The **n8n community** is also a great resource if you run into issues or want to share your OSINT automation successes. Happy automating, and whether your intentions are white, gray, or black hat – use this knowledge responsibly. With great power (of automation) comes great responsibility!
