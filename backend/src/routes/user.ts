import express from "express";
import { login, signup } from "@/services/Authentication";
import { SignInPost, SignUpPost } from "@/interface/api/User";
import { responseHandler } from "@/services/Handler";

// eslint-disable-next-line new-cap
const userRoute = express.Router();

userRoute.post("/signin", async (req, res) => {
	const { email, password }: SignInPost = req.body;
	return responseHandler(res, await login(email, password));
});

userRoute.post("/signup", async (req, res) => {
	const data: SignUpPost = req.body;
	return responseHandler(res, await signup(data));
});

userRoute.post("/forgot", (req, res) => {
	return res.send();
});

userRoute.patch("/reset", (req, res) => {
	return res.send();
});

export default userRoute;
