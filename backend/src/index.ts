import * as chalk from "chalk";

/** Internal Modules */
import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import jwt from "express-jwt";
import cookieParser from "cookie-parser";

/** Routes */
import authRoute from "@/routes/auth";
import profileRoute from "./routes/profile";

/** Misc */
import config from "./config";

import mongoose from "mongoose";
import { House } from "./database/models";
import favoriteRoute from "./routes/favorite";
import offerRoute from "./routes/offer";
import userRoute from "./routes/user";
import searchRoute from "./routes/search";
import storageRoute from "./routes/storage";
import { log } from "./services";

/** Instantiate Application */
const app = express();

/** Express configurations */
dotenv.config();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/** Plugins */
app.use(
	cors({
		origin: "http://localhost:3000",
		credentials: true,
	})
);
app.use(cookieParser());

/** Json Web Token */
app.use(
	jwt({
		secret: config.JWT_SECRET,
		algorithms: ["HS256"],
		credentialsRequired: false,
		getToken: function fromHeaderOrQuerystring(req) {
			if (
				req.headers.authorization &&
				req.headers.authorization.split(" ")[0] === "Bearer"
			) {
				return req.headers.authorization.split(" ")[1];
			} else if (req.query && req.query.token) {
				return req.query.token;
			} else if (req.cookies.token) {
				return req.cookies.token;
			}
			return null;
		},
	})
);

/** Routes */
app.use("/auth", authRoute);
app.use("/profile", profileRoute);
app.use("/favorite", favoriteRoute);
app.use("/offer", offerRoute);
app.use("/search", searchRoute);
app.use("/user", userRoute);
app.use("/storage", storageRoute);

// for testing only
app.get("/api", async (req, res) => {
	// var user1 = new User({
	// 	email: "float@mail.com",
	// 	password: "12345678",
	// 	tel: "0891231234",
	// 	username: "kasemtan",
	// });
	var house1 = new House({
		name: "Korea Condo",
		picture_url:
			"https://transcode-v2.app.engoo.com/image/fetch/f_auto,c_limit,h_256,dpr_3/https://assets.app.engoo.com/images/ZFZlzPBXT8GEoefOiG62vz0oLFY7n2gkvbzGwcQsE0G.jpeg",
		location: {
			type: "Point",
			coordinates: [36.253573, 126.9152424],
		},
		price: 8000,
		status: true,
		tags: ["Korea", "Condo"],
		type: "CONDOMINIUM",
	});

	try {
		// const newUser = await user1.save();
		const newHouse = await house1.save();
		// var favorite1 = new Favorite({
		// 	house_id: newHouse._id,
		// 	user_id: newUser._id,
		// });
		// const newFavorite = await favorite1.save();
		return res.json({ newHouse });
	} catch (e) {
		return res.status(400).json(e);
	}
});

/** Start a server */
mongoose
	.connect(config.MONGODB_HOST)
	.then(() =>
		app.listen(config.PORT, "0.0.0.0", () => {
			log(
				"Server",
				`running on port ${chalk.bold(":" + config.PORT)}`,
				"🚀",
				"😃"
			);
		})
	)
	.catch((err) => console.error("What the fuck is going on??", err));
