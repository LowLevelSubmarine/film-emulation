import {render} from 'preact';
import './style.css';
import {Dispatch, SetStateAction, useEffect, useState} from "react";

export function App() {
  return (
    <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh'}}>
      <Config/>
      <img src={"http://localhost:8080/stream"} alt={'Video Stream'}/>
    </div>
  )
}

function Config() {
  const [grainStrength, setGrainStrength] = useState<number>(0)
  const [dustStrength, setDustStrength] = useState<number>(0);
  const [vignetteStrength, setVignetteStrength] = useState<number>(0);
  const [threshold, setThreshold] = useState<number>(0);
  const [sigmaX, setSigmaX] = useState<number>(0);
  const [crushedLuminanceStrength, setCrushedLuminanceStrength] = useState<number>(0);
  const [gaussianSize, setGaussianSize] = useState<BlurSize>({
    width: 0, height: 0
  });
  const [colorCast, setColorCast] = useState<Color>({
    red: 0,
    blue: 0,
    green: 0
  });

  async function getConfig() {
    const response = await fetch('http://localhost:8080', {method: 'GET'});
    const config: Config = await response.json();
    console.log(config)
    return config
  }

  async function postConfig() {
    const config: Config = {
      grainStrength: grainStrength,
      dustStrength: dustStrength,
      vignetteStrength: vignetteStrength,
      threshold: threshold,
      sigmaX: sigmaX,
      gaussianSize: gaussianSize,
      colorCast: colorCast,
      crushedLuminanceStrength: crushedLuminanceStrength,
    }

    try {
      const response = await fetch('http://localhost:8080', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config),
      })

      if (!response.ok) {
        console.error('Failed to post config:', response.status, response.statusText);
      } else {
        console.log('Configuration updated successfully');
      }
    } catch (error) {
      console.error('Error posting config:', error);
    }
  }

  useEffect(() => {
    getConfig().then(res => {
      setGrainStrength(res.grainStrength)
      setDustStrength(res.dustStrength)
      setVignetteStrength(res.vignetteStrength)
      setThreshold(res.threshold)
      setSigmaX(res.sigmaX)
      setColorCast(res.colorCast)
      setGaussianSize(res.gaussianSize)
      setCrushedLuminanceStrength(res.crushedLuminanceStrength)
    })
  }, [])

  const handleSliderChange = (setter: Dispatch<SetStateAction<number>>) => (event: Event) => {
    const target = event.target as HTMLInputElement;
    setter(parseFloat(target.value));
  }

  const handleComplexSliderChange = <T extends object>(
    setter: Dispatch<SetStateAction<T>>,
    key?: keyof T
  ) => (event: Event) => {
    const target = event.target as HTMLInputElement;
    const value = parseFloat(target.value);

    setter(prevState => {
      if (key) {
        return {...prevState, [key]: value} as T;
      }
      throw new Error("Key must be provided for object updates.");
    });
  };


  return (
    <div style={{padding: 24, display: 'flex', flexDirection: 'column', gap: 12}}>
      <div>
        <h4>Grain</h4>
        <label>
          Strength: {' '}{grainStrength}
          <input type={'range'} step={'0.01'} min={0} max={1} value={grainStrength}
                 onInput={handleSliderChange(setGrainStrength)}/>
        </label>
      </div>
      <div>
        <h4>Dust</h4>
        <label>
          Strength: {' '} {dustStrength}
          <input type={'range'} step={'0.01'} min={0} max={1} value={dustStrength}
                 onInput={handleSliderChange(setDustStrength)}/>
        </label>
      </div>
      <div>
        <h4>Vignette</h4>
        <label>
          Strength: {' '} {vignetteStrength}
          <input type={'range'} step={'0.01'} min={0} max={1} value={vignetteStrength}
                 onInput={handleSliderChange(setVignetteStrength)}/>
        </label>
      </div>
      <div>
        <h4>Color Cast</h4>
        <label>
          Red: {' '} {colorCast.red}
          <input type={'range'} step={'0.01'} min={0} max={1} value={colorCast.red}
                 onInput={handleComplexSliderChange(setColorCast, 'red')}/>
        </label>
        <label>
          Green: {' '} {colorCast.green}
          <input type={'range'} step={'0.01'} min={0} max={1} value={colorCast.green}
                 onInput={handleComplexSliderChange(setColorCast, 'green')}/>
        </label>
        <label>
          Blue: {' '} {colorCast.blue}
          <input type={'range'} step={'0.01'} min={0} max={1} value={colorCast.blue}
                 onInput={handleComplexSliderChange(setColorCast, 'blue')}/>
        </label>
      </div>
      <div>
        <h4>
          Halation
        </h4>
        <label>
          Threshold: {' '} {threshold}
          <input type={'range'} step={'0.01'} min={0} max={100} value={threshold}
                 onInput={handleSliderChange(setThreshold)}/>
        </label>
        <h4>Gaussian Blur</h4>
        <label>
          SigmaX: {' '} {sigmaX}
          <input type={'range'} step={'0.01'} min={0} max={1} value={sigmaX}
                 onInput={handleSliderChange(setSigmaX)}/>
        </label>
        <h4>Gaussian Size</h4>
        <label>
          Width: {' '} {gaussianSize.width}
          <input type={'range'} step={'0.01'} min={0} max={200} value={gaussianSize.width}
                 onInput={handleComplexSliderChange(setGaussianSize, 'width')}/>
        </label>
        <label>
          Height: {' '} {gaussianSize.height}
          <input type={'range'} step={'0.01'} min={0} max={200} value={gaussianSize.height}
                 onInput={handleComplexSliderChange(setGaussianSize, 'height')}/>
        </label>
      </div>
      <div>
        <h4>Crushed Luminance</h4>
        <label>
          Strength: {' '} {crushedLuminanceStrength}
          <input type={'range'} step={'0.01'} min={0} max={1} value={crushedLuminanceStrength}
                 onInput={handleSliderChange(setCrushedLuminanceStrength)}/>
        </label>
      </div>
      <button onClick={postConfig} style={{width: 'fit-content'}}>change config</button>
    </div>
  )
}

render(<App/>, document.getElementById('app'))


interface Config {
  grainStrength: number,
  dustStrength: number,
  vignetteStrength: number,
  threshold: number,
  sigmaX: number,
  gaussianSize: BlurSize,
  colorCast: Color,
  crushedLuminanceStrength: number
}

interface Color {
  red: number,
  green: number,
  blue: number,
}

interface BlurSize {
  width: number,
  height: number,
}
