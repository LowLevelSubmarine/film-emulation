import {useEffect, useMemo, useState} from "react"
import {Config} from "./data"
import {debounce} from "./utils"
import {getConfig, postConfig, resetConfig} from "./api"
import ConfigSlider from "./ConfigSlider"

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
      overflowY: 'auto',
    }}>
      <div>
        <h4>Grain</h4>
        <label>
          Strength: {' '}{config.grainStrength}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.grainStrength}
                        onValue={(value) => updateConfig({...config, grainStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Dust</h4>
        <label>
          Strength: {' '} {config.dustStrength}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.dustStrength}
                        onValue={(value) => updateConfig({...config, dustStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Vignette</h4>
        <label>
          Strength: {' '} {config.vignetteStrength}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.vignetteStrength}
                        onValue={(value) => updateConfig({...config, vignetteStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Color Cast</h4>
        <label>
          Red: {' '} {config.colorCast.red}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.colorCast.red}
                        onValue={(value) => updateConfig({
                          ...config, colorCast: {
                            ...config.colorCast,
                            red: value
                          }
                        })}/>
        </label>
        <label>
          Green: {' '} {config.colorCast.green}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.colorCast.green}
                        onValue={(value) => updateConfig({
                          ...config, colorCast: {
                            ...config.colorCast,
                            green: value
                          }
                        })}/>
        </label>
        <label>
          Blue: {' '} {config.colorCast.blue}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.colorCast.blue}
                        onValue={(value) => updateConfig({
                          ...config, colorCast: {
                            ...config.colorCast,
                            blue: value
                          }
                        })}/>
        </label>
      </div>
      <div>
        <h4>Warm Color Cast</h4>
        <label>
          Red: {' '} {config.warmColorCast.red}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.warmColorCast.red}
                        onValue={(value) => updateConfig({
                          ...config, warmColorCast: {
                            ...config.warmColorCast,
                            red: value
                          }
                        })}/>
        </label>
        <label>
          Green: {' '} {config.warmColorCast.green}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.warmColorCast.green}
                        onValue={(value) => updateConfig({
                          ...config, warmColorCast: {
                            ...config.warmColorCast,
                            green: value
                          }
                        })}/>
        </label>
        <label>
          Blue: {' '} {config.warmColorCast.blue}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.warmColorCast.blue}
                        onValue={(value) => updateConfig({
                          ...config, warmColorCast: {
                            ...config.warmColorCast,
                            blue: value
                          }
                        })}/>
        </label>
      </div>
      <div>
        <h4>Cold Color Cast</h4>
        <label>
          Red: {' '} {config.coldColorCast.red}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.coldColorCast.red}
                        onValue={(value) => updateConfig({
                          ...config, coldColorCast: {
                            ...config.coldColorCast,
                            red: value
                          }
                        })}/>
        </label>
        <label>
          Green: {' '} {config.coldColorCast.green}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.coldColorCast.green}
                        onValue={(value) => updateConfig({
                          ...config, coldColorCast: {
                            ...config.coldColorCast,
                            green: value
                          }
                        })}/>
        </label>
        <label>
          Blue: {' '} {config.coldColorCast.blue}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.coldColorCast.blue}
                        onValue={(value) => updateConfig({
                          ...config, coldColorCast: {
                            ...config.coldColorCast,
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
          Strength: {' '} {config.halationStrength}
          <ConfigSlider step={'0.01'} min={0} max={100} value={config.halationStrength}
                        onValue={(value) => updateConfig({...config, halationStrength: value})}/>
        </label>
        <label>
          Threshold: {' '} {config.halationThreshold}
          <ConfigSlider step={'0.01'} min={0} max={100} value={config.halationThreshold}
                        onValue={(value) => updateConfig({...config, halationThreshold: value})}/>
        </label>
        <h4>Gaussian Blur</h4>
        <label>
          Width: {' '} {config.halationGaussianSize.width}
          <ConfigSlider step={'0.01'} min={0} max={200} value={config.halationGaussianSize.width}
                        onValue={(value) => updateConfig({
                          ...config, halationGaussianSize: {
                            ...config.halationGaussianSize,
                            width: value
                          }
                        })}/>
        </label>
        <label>
          Height: {' '} {config.halationGaussianSize.height}
          <ConfigSlider step={'0.01'} min={0} max={200} value={config.halationGaussianSize.height}
                        onValue={(value) => updateConfig({
                          ...config, halationGaussianSize: {
                            ...config.halationGaussianSize,
                            height: value
                          }
                        })}/>
        </label>
      </div>
      <div>
        <h4>Crushed Luminance</h4>
        <label>
          Strength: {' '} {config.crushedLuminanceStrength}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.crushedLuminanceStrength}
                        onValue={(value) => updateConfig({...config, crushedLuminanceStrength: value})}/>
        </label>
      </div>
      <div>
        <h4>Gate Weave</h4>
        <label>
          Jitter Scale: {' '} {config.jitterScale}
          <ConfigSlider step={'0.0001'} min={0} max={0.01} value={config.jitterScale}
                        onValue={(value) => updateConfig({...config, jitterScale: value})}/>
        </label>
        <label>
          Weave Noise Speed: {' '} {config.weaveNoiseSpeed}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.weaveNoiseSpeed}
                        onValue={(value) => updateConfig({...config, weaveNoiseSpeed: value})}/>
        </label>
        <label>
          Weave Noise Scale: {' '} {config.weaveNoiseScale}
          <ConfigSlider step={'0.01'} min={0} max={1} value={config.weaveNoiseScale}
                        onValue={(value) => updateConfig({...config, weaveNoiseScale: value})}/>
        </label>
      </div>
      <button onClick={() => resetConfig().then(res => setConfig(res))}>reset config</button>
    </div>
  )
}