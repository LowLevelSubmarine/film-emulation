import {useEffect, useMemo, useState} from "react"
import {Config} from "./data"
import {debounce} from "./utils"
import {getConfig, postConfig, resetConfig} from "./api"
import CoolSlider from "./CoolSlider"

export default function ConfigUi() {
  const [config, setConfig] = useState<Config>()

  const postConfigDebounced = useMemo(() => debounce((config: Config) => {
    postConfig(config).then()
  }, 300), [])

  useEffect(() => {
    getConfig().then(res => {
      setConfig(res)
    })
  }, [])

  function updateConfig(config: Config) {
    postConfigDebounced(config)
    setConfig(config)
  }

  if (!config) return <p>Loading ...</p>

  return (
    <div style={{
      padding: 24,
      display: 'flex',
      flexDirection: 'column',
      gap: 12,
      width: 250,
      height: '100%',
      justifyContent: 'center'
    }}>
      <div>
        <h4>Grain</h4>
        <label>
          Strength: {' '}{config.grainStrength}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.grainStrength}
                      onValue={(value) => updateConfig({...config, grainStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Dust</h4>
        <label>
          Strength: {' '} {config.dustStrength}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.dustStrength}
                      onValue={(value) => updateConfig({...config, dustStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Vignette</h4>
        <label>
          Strength: {' '} {config.vignetteStrength}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.vignetteStrength}
                      onValue={(value) => updateConfig({...config, vignetteStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Color Cast</h4>
        <label>
          Red: {' '} {config.colorCast.red}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.colorCast.red}
                      onValue={(value) => updateConfig({
                        ...config, colorCast: {
                          ...config.colorCast,
                          red: value
                        }
                      })}/>
        </label>
        <label>
          Green: {' '} {config.colorCast.green}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.colorCast.green}
                      onValue={(value) => updateConfig({
                        ...config, colorCast: {
                          ...config.colorCast,
                          green: value
                        }
                      })}/>
        </label>
        <label>
          Blue: {' '} {config.colorCast.blue}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.colorCast.blue}
                      onValue={(value) => updateConfig({
                        ...config, colorCast: {
                          ...config.colorCast,
                          blue: value
                        }
                      })}/>
        </label>
      </div>
      <div>
        <h4>
          Halation
        </h4>
        <label>
          Threshold: {' '} {config.threshold}
          <CoolSlider step={'0.01'} min={0} max={100} value={config.threshold}
                      onValue={(value) => updateConfig({...config, threshold: value})}/>
        </label>
        <h4>Gaussian Blur</h4>
        <label>
          Width: {' '} {config.gaussianSize.width}
          <CoolSlider step={'2'} min={1} max={199} value={config.gaussianSize.width}
                      onValue={(value) => updateConfig({
                        ...config, gaussianSize: {
                          ...config.gaussianSize,
                          width: value
                        }
                      })}/>
        </label>
        <label>
          Height: {' '} {config.gaussianSize.height}
          <CoolSlider step={'2'} min={1} max={199} value={config.gaussianSize.height}
                      onValue={(value) => updateConfig({
                        ...config, gaussianSize: {
                          ...config.gaussianSize,
                          height: value
                        }
                      })}/>
        </label>
      </div>
      <div>
        <h4>Crushed Luminance</h4>
        <label>
          Strength: {' '} {config.crushedLuminanceStrength}
          <CoolSlider step={'0.01'} min={0} max={1} value={config.crushedLuminanceStrength}
                      onValue={(value) => updateConfig({...config, crushedLuminanceStrength: value})}/>
        </label>
      </div>
      <button onClick={() => resetConfig().then(res => setConfig(res))}>reset config</button>
    </div>
  )
}