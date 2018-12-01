import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Elm.Main.init({
  node: document.getElementById('root')
});

registerServiceWorker();

const outboundPortHandlers = {
  SetTitle: title => {
    document.title = title;
  }
};

const handleOutboundPort = evt => {
  outboundPortHandlers[evt.type](evt.payload);
};

app.ports.outbound.subscribe(handleOutboundPort);