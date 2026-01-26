// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import TreeBuilderHook from "../../vendor/selecto_components/lib/selecto_components/components/tree_builder.hooks"
import selectoHooks from "../../vendor/selecto_components/assets/js/hooks"
import {hooks as colocatedHooks} from "phoenix-colocated/selecto_northwind"
import topbar from "../vendor/topbar"

// Import Chart.js for SelectoComponents graph visualization
import Chart from "chart.js/auto"
window.Chart = Chart

// Import Alpine.js for enhanced interactivity
import Alpine from "alpinejs"
window.Alpine = Alpine
Alpine.start()

// Tutorial code block functionality
const TutorialCodeBlocks = {
  mounted() {
    this.addCopyButtons()
    this.addSyntaxHighlighting()
  },
  
  addCopyButtons() {
    const codeBlocks = document.querySelectorAll('.tutorial-code-block')
    
    codeBlocks.forEach(block => {
      const copyButton = document.createElement('button')
      copyButton.className = 'absolute top-2 right-2 btn btn-xs btn-ghost opacity-60 hover:opacity-100'
      copyButton.innerHTML = `
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
        </svg>
        Copy
      `
      
      copyButton.addEventListener('click', () => {
        const code = block.querySelector('code')
        const text = code.textContent
        
        navigator.clipboard.writeText(text).then(() => {
          copyButton.innerHTML = `
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            Copied!
          `
          setTimeout(() => {
            copyButton.innerHTML = `
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
              </svg>
              Copy
            `
          }, 2000)
        })
      })
      
      block.style.position = 'relative'
      block.appendChild(copyButton)
    })
  },
  
  addSyntaxHighlighting() {
    const codeElements = document.querySelectorAll('code[data-language]')
    
    codeElements.forEach(code => {
      const language = code.dataset.language
      this.highlightCode(code, language)
    })
  },
  
  highlightCode(element, language) {
    const text = element.textContent
    let highlightedText = text
    
    if (language === 'elixir') {
      // Basic Elixir syntax highlighting
      highlightedText = text
        .replace(/\b(defmodule|def|defp|end|do|use|import|alias|require|if|unless|case|cond|with|fn)\b/g, 
                '<span class="text-purple-400 font-semibold">$1</span>')
        .replace(/\b(true|false|nil)\b/g, '<span class="text-blue-400">$1</span>')
        .replace(/:([a-zA-Z_][a-zA-Z0-9_]*)/g, '<span class="text-green-400">:$1</span>')
        .replace(/"([^"]*)"/g, '<span class="text-yellow-300">"$1"</span>')
        .replace(/#.*/g, '<span class="text-gray-400 italic">$&</span>')
    } else if (language === 'bash') {
      // Basic bash syntax highlighting
      highlightedText = text
        .replace(/^(\$ |# )/gm, '<span class="text-green-400 font-semibold">$1</span>')
        .replace(/\bmix\b/g, '<span class="text-purple-400 font-semibold">mix</span>')
        .replace(/\b(git|cd|npm)\b/g, '<span class="text-blue-400 font-semibold">$1</span>')
    }
    
    element.innerHTML = highlightedText
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, TreeBuilder: TreeBuilderHook, ...selectoHooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Initialize tutorial code blocks when the page loads
document.addEventListener('DOMContentLoaded', () => {
  TutorialCodeBlocks.mounted()
})

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

