//For anything that can light stuff on fire
/obj/item/flame
	var/lit_heat = 1000
	var/waterproof = FALSE
	var/lit = FALSE
	material = /decl/material/solid/organic/wood

/obj/item/flame/get_tool_quality(archetype)
	return (!lit && archetype == TOOL_CAUTERY) ? TOOL_QUALITY_NONE : ..()

/obj/item/flame/proc/extinguish(var/mob/user, var/no_message)
	lit = FALSE
	damtype = BRUTE
	update_force()
	STOP_PROCESSING(SSobj, src)

/obj/item/flame/fluid_act(var/datum/reagents/fluids)
	..()
	if(!QDELETED(src) && fluids?.total_volume && !waterproof && lit)
		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 5) // Potentially set fire to fuel etc.
		extinguish(no_message = TRUE)

/obj/item/flame/proc/light(mob/user, no_message)
	if(lit)
		return
	lit = TRUE
	damtype = BURN
	update_force()
	update_icon()

/obj/item/flame/get_heat()
	. = max(..(), lit ? lit_heat : 0)

/obj/item/flame/isflamesource()
	. = lit

///////////
//MATCHES//
///////////
/obj/item/flame/match
	name = "match"
	desc = "A simple match stick, used for lighting fine smokables."
	icon = 'icons/obj/items/storage/matches/match.dmi'
	icon_state = ICON_STATE_WORLD
	var/burnt = 0
	var/smoketime = 5
	obj_flags = OBJ_FLAG_HOLLOW // so that it's not super overpriced compared to lighters
	w_class = ITEM_SIZE_TINY
	origin_tech = @'{"materials":1}'
	slot_flags = SLOT_EARS
	attack_verb = list("burnt", "singed")
	randpixel = 10
	max_force = 1

/obj/item/flame/match/light(mob/user, no_message)
	if(burnt)
		return
	if(lit)
		return
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/flame/match/Process()
	if(isliving(loc))
		var/mob/living/M = loc
		M.IgniteMob()
	var/turf/location = get_turf(src)
	smoketime--
	if(submerged() || smoketime < 1)
		extinguish()
		return
	if(location)
		location.hotspot_expose(700, 5)

/obj/item/flame/match/dropped(var/mob/user)
	//If dropped, put ourselves out
	//not before lighting up the turf we land on, though.
	if(lit)
		var/turf/location = src.loc
		if(istype(location))
			location.hotspot_expose(700, 5)
		extinguish()
	return ..()

/obj/item/flame/match/extinguish(var/mob/user, var/no_message, var/burn = TRUE)
	. = ..()
	if(burn)
		name = "burnt match"
		desc = "A match. This one has seen better days."
		burnt = TRUE
		update_icon()

/obj/item/flame/match/on_update_icon()
	. = ..()
	if(burnt)
		icon_state = "[get_world_inventory_state()]_burnt"
	else if(lit)
		icon_state = "[get_world_inventory_state()]_lit"