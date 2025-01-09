import { render } from 'preact';

import preactLogo from './assets/preact.svg';
import './style.css';
import {useEffect, useState} from "react";

export function App() {
	return (
		<div>
			<Config/>
			<img src={"http://localhost:8080/stream"}/>
		</div>
	);
}

function Config() {
	const [grainStrength, setGrainStrength] = useState<number>()
	const [dustStrength, setDustStrength] = useState<number>();

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
		};

		try {
			const response = await fetch('http://localhost:8080', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify(config),
			});

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
		})
	}, [])

	const handleSliderChange = (setter: React.Dispatch<React.SetStateAction<number>>) => (event: Event) => {
		const target = event.target as HTMLInputElement;
		setter(parseFloat(target.value));
	};

	return(
		<>
			<label>
				Grain Strength: {' '}
				<input type={'range'} step={'0.01'} min={0} max={1} value={grainStrength} onInput={handleSliderChange(setGrainStrength)}/>
			</label>
			<p>{grainStrength}</p>
			<br/>
			<label>
				Dust Strength:  {' '}
				<input type={'range'} step={'0.01'} min={0} max={1} value={dustStrength} onInput={handleSliderChange(setDustStrength)}/>
			</label>
			<p>{dustStrength}</p>

			<button onClick={postConfig}>change config</button>
		</>
	);
}

render(<App />, document.getElementById('app'));


interface Config {
	grainStrength: number,
	dustStrength: number
}
