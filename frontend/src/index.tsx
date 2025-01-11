import { render } from 'preact';

import preactLogo from './assets/preact.svg';
import './style.css';
import {useEffect, useState} from "react";

export function App() {
	return (
		<div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh'}}>
			<Config/>
			<img src={"http://localhost:8080/stream"} alt={'Video Stream'}/>
		</div>
	)
}

function Config() {
	const [grainStrength, setGrainStrength] = useState<number>()
	const [dustStrength, setDustStrength] = useState<number>();
	const [vignetteStrength, setVignetteStrength] = useState<number>();
	const [threshold, setThreshold] = useState<number>();
	const [sigmaX, setSigmaX] = useState<number>();
	const [gaussianSize, setGaussianSize] = useState<BlurSize>();
	const [colorCast, setColorCast] = useState<Color>();

	async function getConfig() {
		const response = await fetch('http://localhost:8080', {method: 'GET'});
		const config: Config = await response.json();
		console.log(config)
		return config
	}

	async function postConfig() {
		const config: Config = {
			grainStrength: grainStrength ?? 0, // Default zu 0, wenn undefined
			dustStrength: dustStrength ?? 0,  // Default zu 0, wenn undefined
			vignetteStrength: vignetteStrength ?? 0,
			threshold: threshold ?? 0,
			sigmaX: sigmaX ?? 0,
			gaussianSize: gaussianSize ?? {
				width: 0,
				height: 0,
			},
			colorCast: colorCast ?? {
				red: 0,
				green: 0,
				blue: 0
			}
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
			setGaussianSize(res.gaussianSize)
			setColorCast(res.colorCast)
		})
	}, [])

	const handleSliderChange = (setter: React.Dispatch<React.SetStateAction<number>>) => (event: Event) => {
		const target = event.target as HTMLInputElement;
		setter(parseFloat(target.value));
	}

	return(
		<div style={{padding: 24, display: 'flex', flexDirection: 'column', gap: 12}}>
				<label>
					Grain Strength: {' '}{grainStrength}
					<input type={'range'} step={'0.01'} min={0} max={1} value={grainStrength}
								 onInput={handleSliderChange(setGrainStrength)}/>
				</label>
				<label>
					Dust Strength: {' '} {dustStrength}
					<input type={'range'} step={'0.01'} min={0} max={1} value={dustStrength}
								 onInput={handleSliderChange(setDustStrength)}/>
				</label>
				<label>
					Vignette Strength: {' '} {vignetteStrength}
					<input type={'range'} step={'0.01'} min={0} max={1} value={vignetteStrength}
								 onInput={handleSliderChange(setVignetteStrength)}/>
				</label>
				<label>
					Color Cast: {' '} {colorCast}
					{/*<input type={'range'} step={'0.01'} min={0} max={1} value={vignetteStrength}*/}
					{/*			 onInput={handleSliderChange(setVignetteStrength)}/>*/}
				</label>
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
