import {render} from 'preact'
import './style.css'
import ConfigUi from "./ConfigUi"
import VideoStream from "./VideoStream"

export function App() {
  return (
    <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh'}}>
      <ConfigUi/>
      <VideoStream/>
    </div>
  )
}

render(<App/>, document.getElementById('app'))
