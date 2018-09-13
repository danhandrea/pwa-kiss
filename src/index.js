import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
var storageKey = "store";
var flags = localStorage.getItem(storageKey);
var app = Elm.Main.init({flags: flags});

console.log(app.ports)

// app.ports.storeCache.subscribe(function(val) {
//     if (val === null) {
//       localStorage.removeItem(storageKey);
//     } else {
//       localStorage.setItem(storageKey, JSON.stringify(val));
//     }
//     // Report that the new session was stored succesfully.
//     setTimeout(function() { app.ports.onStoreChange.send(val); }, 0);
//   });


  // Whenever localStorage changes in another tab, report it if necessary.
  window.addEventListener("storage", function(event) {
    if (event.storageArea === localStorage && event.key === storageKey) {
      app.ports.onStoreChange.send(event.newValue);
    }
  }, false);

registerServiceWorker();
