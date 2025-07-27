<script setup lang="ts">
// External Libraries
import { computed, onMounted, onBeforeUnmount } from "vue"

// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

import { useConfigStore } from "@/stores/config"
const configStore = useConfigStore()

// Composables
import { useBridge } from "@/composables/useBridge"
const { handleMessage } = useBridge()

// Utils
import { callback } from "@/utils/callback"
import { DEV_MODE } from "@/utils/constants"

// Components
import MainHeader from "@/components/MainHeader.vue"
import CategoryList from "@/components/CategoryList.vue"
import ItemList from "@/components/ItemList.vue"
import CartItems from "@/components/CartItems.vue"
import CartPayment from "@/components/CartPayment.vue"

const devStyles = computed(() => {
  return {
    backgroundImage: `url(${new URL("@/assets/img/evening-bg.png", import.meta.url)})`,
    backgroundSize: "cover",
    backgroundRepeat: "no-repeat",
  }
})

const closeShop = (): void => {
  callback({ action: "closeShop" })
}

const handleKeyup = (event: KeyboardEvent): void => {
  if (event.key !== "Escape") return
  closeShop()
}

onMounted(() => {
  window.addEventListener("message", handleMessage)
  window.addEventListener("keyup", handleKeyup)
})

onBeforeUnmount(() => {
  window.removeEventListener("message", handleMessage)
  window.removeEventListener("keyup", handleKeyup)
})
</script>

<template>
  <transition name="fade-transition">
    <main v-if="shopStore.showShop" class="shop-container" id="app" :style="DEV_MODE ? devStyles : {}">
      <div class="shop-layout">
        <section class="shop-left">
          <div class="shop-left-header">
            <MainHeader :locales="configStore.locales.main.header" position="left" />
            <CategoryList />
          </div>
          <ItemList />
        </section>

        <section class="shop-right">
          <MainHeader :locales="configStore.locales.cart.header" position="right" />
          <div class="shop-cart">
            <CartItems />
            <CartPayment />
          </div>
        </section>
      </div>
    </main>
  </transition>
</template>

<style scoped>
.shop-container {
  position: absolute;
  inset: 0;
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  overflow: hidden;
  background-color: rgba(10, 10, 10, 0.93);

  .shop-layout {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    width: 100vw;
    height: 100vh;
    padding: 8vh;
    gap: 0.5vh;
  }
}

.fade-transition {
  &-enter-active,
  &-leave-active {
    transition: opacity 0.25s ease;
  }
  &-enter-from,
  &-leave-to {
    opacity: 0;
  }
  &-leave-from,
  &-enter-to {
    opacity: 1;
  }
}

.shop-left {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-start;
  width: 70%;
  height: 100%;
  gap: 2vh;

  .shop-left-header {
    display: flex;
    flex-direction: column;
    width: 100%;
  }
}

.shop-right {
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: flex-end;
  width: 27.5%;
  height: 100%;
  gap: 2vh;

  .shop-cart {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    width: 100%;
    height: 100%;
  }
}
</style>
