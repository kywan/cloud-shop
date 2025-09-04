import { defineStore } from "pinia"

export const useConfigStore = defineStore("config", () => {
  const imagePath = <string>"item_images/"

  const soundVolume = <number>0.5

  const locales = <Locales>{
    currency: {
      symbol: "$",
      position: "before",
    },

    main: {
      header: {
        title: "Market",
        tag: "24/7",
        description:
          "Welcome to your local market, where we're always here for you, day or night!\nExplore a curated selection of premium goods, tailored to meet your every need.",
      },
      item: {
        add_cart: "Add To Cart",
      },
    },

    cart: {
      header: {
        title: "Shopping",
        tag: "Cart",
        description: "Review your chosen items and proceed to secure, easy\ncheckout with multiple payment options.",
      },
      payment: {
        title: "Payment",
        pay_bank: "Card",
        pay_cash: "Cash",
      },
    },
  }

  return {
    imagePath,
    soundVolume,
    locales,
  }
})
