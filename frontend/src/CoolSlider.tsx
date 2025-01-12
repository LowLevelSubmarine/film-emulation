export default function CoolSlider(
  {
    step,
    value,
    min,
    max,
    onValue
  }: {
    step: string,
    value: number,
    min: number,
    max: number,
    onValue: (value: number) => void
  }) {
  return <input id={'coolSlider'} type={'range'} step={step} min={min} max={max} value={value}
                style={{
                  background: `linear-gradient(to right, #eee 0%, #eee ${
                    ((value - min) / (max - min)) * 100
                  }%, #111 ${
                    ((value - min) / (max - min)) * 100
                  }%, #111 100%)`,
                }}
                onInput={(event) => {
                  const target = event.target as HTMLInputElement
                  onValue(parseFloat(target.value))
                }}/>
}