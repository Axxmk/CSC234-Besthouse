import { OfferPatch } from "@/interface/api/OfferType";
import { responseHandler } from "@/services/Handler";
import { DeleteOffer, GetOfferInfo, UpdateOffer } from "@/services/House";
import express from "express";
import { Types } from "mongoose";

const offerRoute = express.Router();

offerRoute.get("/", (req, res) => {});

offerRoute.get("/:id", async (req, res) => {
	const { id } = req.params;
	const house_id = new Types.ObjectId(id);
	return responseHandler(res, await GetOfferInfo(house_id));
});

offerRoute.post("/", (req, res) => {});

offerRoute.patch("/:id", async (req, res) => {
	// get params
	const { id } = req.params;
	const house_id = new Types.ObjectId(id);
	const body: OfferPatch = req.body;
	return responseHandler(res, await UpdateOffer(house_id, body, req));
});

offerRoute.delete("/:id", async (req, res) => {
	const { id } = req.params;
	const house_id = new Types.ObjectId(id);
	return responseHandler(res, await DeleteOffer(house_id, req));
});

export default offerRoute;
