export function debounce<T extends (...args: any[]) => void>(func: T, wait: number): T {
  let timeoutId: number
  return function (...args: Parameters<T>) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => func(...args), wait)
  } as T
}