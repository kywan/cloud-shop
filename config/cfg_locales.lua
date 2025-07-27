return {
	ui = {
		currency = "$",
		main = {
			item = {
				add_cart = "Add To Cart",
			},
		},
		cart = {
			payment = {
				title = "Payment",
				pay_bank = "Bank",
				pay_cash = "Cash",
			},
		},
	},

	interaction = {
		help_text = "~INPUT_CONTEXT~  View Product Catalog", --? Button Reference: https://docs.fivem.net/docs/game-references/controls
		floating_text = "~INPUT_CONTEXT~ View Product Catalog", --? Button Reference: https://docs.fivem.net/docs/game-references/controls
		target = {
			icon = "fa-solid fa-cart-shopping", --? Icon Reference: https://fontawesome.com/icons
			label = "View Product Catalog",
		},
	},

	dialog = {
		license = {
			header = "A **%s** is required to access this shop!",
			content = "Would you like to purchase a **%s** for **$%s**?",
		},
	},

	notify = {
		requirement = {
			job = { title = "Access Requirement", description = "The **%s** job is required to access this shop!", type = "warning" },
			job_grade = { title = "Access Requirement", description = "Your job grade doesn't meet the requirements to access this shop!.", type = "warning" },
			license = { title = "Access Requirement", description = "A **%s** is required to access this shop!", type = "warning" },
		},
		cant_carry = {
			item = { title = "Carry Restriction", description = "You cannot carry the **%s**.", type = "error" },
			weapon = { title = "Carry Restriction", description = "You cannot carry multiple **%s*'s*.", type = "error" },
		},
		no_money = {
			shop = { title = "Insufficient Funds", description = "You do not have enough money to pay for your purchase.", type = "error" },
			license = { title = "Insufficient Funds", description = "You don't have enough money to buy the **%s**.", type = "error" },
		},
		payment_success = {
			shop = { title = "Purchase Complete", description = "Successfully purchased item(s) for **$%s**.", type = "success" },
			license = { title = "Purchase Complete", description = "Successfully purchased a **%s** for **$%s**.", type = "success" },
		},
	},
}
