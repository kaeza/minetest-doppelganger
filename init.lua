
---------------------------
---- ENTITY DEFINITION ----
---------------------------

local doppelganger_entity = {
	hp_max = 100,
}

function doppelganger_entity:on_activate(staticdata)
	self.object:set_properties({
		visual = "mesh",
		mesh = "character.x",
		textures = { "character.png", },
	})
	self.object:set_armor_groups({immortal=1})
	local meta
	if staticdata and (staticdata ~= "") then
		meta = minetest.deserialize(staticdata)
	end
	self.owner = meta and meta.owner
end

function doppelganger_entity:get_staticdata()
	return minetest.serialize({
		owner = self.owner,
	})
end

function doppelganger_entity:on_punch(puncher)
	local name = puncher:get_player_name()
	--[[if name ~= self.owner then
		minetest.chat_send_player(name, "My owner is "..(self.owner or "NIL???").."!")
		return
	end]]
	local ctrl = puncher:get_player_control()
	if ctrl.sneak then
		local inv = puncher:get_inventory()
		local stack = ItemStack({
			name = "doppelganger:spawner",
			count = 1,
			metadata = self:get_staticdata(),
		})
		print("[doppelganger] DEBUG: meta="..(stack:get_metadata() or "NIL???"))
		if (not minetest.setting_getbool("creative_mode"))
		 and inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		elseif minetest.setting_getbool("creative_mode")
		 and (not inv:contains_item("main", stack)) then
			inv:add_item("main", stack)
		end
		self.object:remove()
	else
		self.object:set_properties({
			visual = "mesh",
			mesh = "character.x",
			textures = { "player_"..name..".png", },
		})
	end
end

----------------------------
---- SPAWNER DEFINITION ----
----------------------------

local doppelganger_spawner = {
	description = "Doppelganger",
	inventory_image = "character.png",
	stack_max = 1,
}

function doppelganger_spawner.on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local name = placer:get_player_name()
	local p1 = pointed_thing.above
	local p2 = { x=p1.x, y=p1.y, z=p1.z }
	p2.y = p2.y + 1
	local def1 = minetest.registered_nodes[minetest.get_node(p1).name]
	local def2 = minetest.registered_nodes[minetest.get_node(p2).name]
	if (def1.walkable) or (def2.walkable) then
		minetest.chat_send_player(name, "Not enough space to place doppelganger.")
		return
	end
	p1.y = p1.y + 0.5
	local obj = minetest.add_entity(p1, "doppelganger:entity")
	local ent = obj:get_luaentity()
	local meta = itemstack:get_metadata()
	ent.owner = meta or name
	if meta or (not minetest.setting_getbool("creative_mode")) then
		itemstack:take_item(1)
	end
	return itemstack
end

----------------------
---- REGISTRATION ----
----------------------

minetest.register_entity("doppelganger:entity", doppelganger_entity)
minetest.register_craftitem("doppelganger:spawner", doppelganger_spawner)
