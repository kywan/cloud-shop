import { useConfigStore } from "@/stores/config"

export const getImageSrc = (name: string): string | undefined => {
  const configStore = useConfigStore()

  if (!name || typeof name !== "string") return undefined
  return `${configStore.imagePath}${name}.png`
}

export const onImageError = (event: Event) => {
  const target = event.target as HTMLImageElement | null
  if (!target) return
  target.src = "item_images/fallback-item.webp"
}
