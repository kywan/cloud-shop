import { useConfigStore } from "@/stores/config"

export function playSound(src: string, volumeMultiplier?: number) {
  const configStore = useConfigStore()

  const audio = new Audio(src)
  audio.volume = Math.max(0, Math.min(configStore.soundVolume * (volumeMultiplier || 1), 1))
  audio.play()
}
