import { House, HouseDetail, Favorite } from "@/database/models";
import { OfferPatch } from "@/interface/api/OfferType";
import { Types, Schema } from "mongoose";
import { FavouritePost } from "@/interface/api/FavoritePost";
import { Request } from "express";
import { genericError, infoResponse } from "./Handler";
import { isLogin } from "./Utils";

export const getOfferInfo = async (house_id: Types.ObjectId) => {
	try {
		const house = await House.findById(house_id);
		const houseDetail = await HouseDetail.findOne({ house_id: house_id });

		return infoResponse({ ...house, ...houseDetail });
	} catch (error) {
		return genericError(error.message, 500);
	}
};

export const updateOffer = async (
	house_id: Types.ObjectId,
	body: OfferPatch,
	req: Request
) => {
	try {
		if (!isLogin(req)) {
			return genericError(
				"Unauthorize: Login is required to do function",
				400
			);
		}

		const user_id = req.user.user_id;

		// check permission
		const houseDetail = await HouseDetail.findOne({
			user_id: user_id,
			house_id: house_id,
		}).exec();

		if (houseDetail == null) {
			return genericError("Unauthorize: User is not own this offer", 400);
		}

		// update house and houseDetail
		try {
			await House.updateOne(
				{ _id: house_id },
				{
					$set: {
						name: body.name,
						location: body.location,
						picture_url: body.picture_url,
						tags: body.tags,
					},
				}
			).exec();
			await houseDetail
				.updateOne({
					$set: {
						description: body.description,
						electric_fee: body.electric_fee,
						facilities: body.facilities,
						house_id: house_id,
						price: body.price,
						rooms: body.rooms,
						total_size: body.total_size,
						type: body.type,
					},
				})
				.exec();
		} catch (error) {
			return genericError(error.message, 400);
		}

		return infoResponse(null, "offer edited");
	} catch (error) {
		return genericError(error.message, 500);
	}
};

export const deleteOffer = async (house_id: Types.ObjectId, req: Request) => {
	try {
		if (!isLogin(req)) {
			return genericError(
				"Unauthorize: Login is required to do function",
				400
			);
		}

		const user_id = req.user.user_id;

		const houseDetail = await HouseDetail.findOne({
			user_id: user_id,
			house_id: house_id,
		}).exec();

		if (houseDetail == null) {
			return genericError("Unauthorize: User is not own this offer", 400);
		}

		await houseDetail.delete().exec();
		return infoResponse(null, "offer deleted!");
	} catch (error) {
		return genericError(error.message, 500);
	}
};

export const listFavoriteHouse = async (req: Request) => {
	try {
		if (!isLogin(req)) {
			return genericError(
				"Unauthorize: Login is required to do function",
				400
			);
		}

		const user_id = req.user.user_id;

		// Fetch favorite list from userid
		const housesId = await Favorite.find(
			{ user_id: user_id },
			"house_id"
		).exec();
		const ids: Schema.Types.ObjectId[] = housesId.map((e) => e.house_id);

		// Fetch houses from favourite
		const houses = await House.find({ _id: { $in: ids } }).exec();
		return infoResponse(houses);
	} catch (error) {
		return genericError(error.message, 500);
	}
};

export const favoriteHouse = async (body: FavouritePost, req: Request) => {
	try {
		if (!isLogin(req)) {
			return genericError(
				"Unauthorize: Login is required to do function",
				400
			);
		}

		const user_id = req.user.user_id;

		// check if the user favorited or not
		const favorite = await Favorite.findOne({
			house_id: body.house_id,
			user_id: user_id,
		});

		if (favorite) {
			await favorite.remove();
			return infoResponse(null, "Removed from favorite");
		}

		await new Favorite({
			house_id: body.house_id,
			user_id: user_id,
		}).save();
		return infoResponse(null, "Added to favorite!");
	} catch (error) {
		return genericError(error.message, 500);
	}
};