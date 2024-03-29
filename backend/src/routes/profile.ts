import express from "express";
import {
	GetUser,
	GetUserById,
	PatchUser,
	PatchUserPicture,
} from "@/services/User";
import { responseHandler } from "@/services/Handler";
import { ProfilePatch, UserPatch } from "@/interface/api/ProfilePatch";

// eslint-disable-next-line new-cap
const profileRoute = express.Router();

profileRoute.get("/", async (req, res) => {
	return responseHandler(res, await GetUser(req));
});

profileRoute.get("/:id", async (req, res) => {
	const { id } = req.params;
	return responseHandler(res, await GetUserById(id));
});

profileRoute.patch("/picture", async (req, res) => {
	return responseHandler(res, await PatchUserPicture(req));
});

profileRoute.patch("/", async (req, res) => {
	const bodyProfile: ProfilePatch = req.body;
	const bodyUser: UserPatch = req.body;
	return responseHandler(res, await PatchUser(req, bodyProfile, bodyUser));
});

export default profileRoute;
