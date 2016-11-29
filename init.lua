--[[
GOALS

######make a playset base thing that allows players to add nodes in mini form above

-Make it so you can place in your real items


]]--


nano_blocks = {}
nano_blocks.size = 8

minetest.register_entity("nano_blocks:block", {
    hp_max = 1,
    physical = true,
    --collide_with_objects = false,
    collisionbox = {-0.5/nano_blocks.size,-0.5/nano_blocks.size,-0.5/nano_blocks.size, 0.5/nano_blocks.size,0.5/nano_blocks.size,0.5/nano_blocks.size},
    visual = "wielditem",
    visual_size = {x=0.667/nano_blocks.size, y=0.667/nano_blocks.size},
    textures={"air"},
    --nodename = "",
    old_nodename = "",
    makes_footstep_sound = false,
    set_node = function(self,dtime)
		if self.nodename == nil then
			self.nodename = "default:dirt_with_grass"
		end
		self.texture = ItemStack(self.nodename):get_name()
		self.old_nodename = self.nodename
		self.object:set_properties({textures={self.texture}})
    end,

    on_activate = function(self,dtime)
		self.set_node(self,dtime)
    end,
    
    on_rightclick = function(self,clicker)
		local pos = self.object:getpos()
		local dir = clicker:get_look_dir()
		local wallmounted = minetest.dir_to_wallmounted(dir)
		local add_dir = minetest.wallmounted_to_dir(wallmounted)
		add_dir.x = add_dir.x * -1
		add_dir.y = add_dir.y * -1
		add_dir.z = add_dir.z * -1
		
		local node = minetest.add_entity({x=pos.x+(add_dir.x/nano_blocks.size),y = pos.y+(add_dir.y/nano_blocks.size), z=pos.z+(add_dir.z/nano_blocks.size)}, "nano_blocks:block")
		
		local item = clicker:get_wielded_item():to_table()
		
		if item ~= nil then
			node:get_luaentity().nodename = item.name
		end
		
		if minetest.setting_getbool("creative_mode") == false then
			local inv = clicker:get_inventory()
			local index = clicker:get_wield_index()
			
			if item.count - 1 == 0 then
				item.name = ""
			end
			
			
			inv:set_stack("main", index, item.name.." "..item.count-1)
		end
    end,

    on_punch = function(self,dtime)
		if minetest.setting_getbool("creative_mode") == false then
			minetest.add_item(self.object:getpos(),self.nodename)
		end
		self.object:remove()
    end,
    
    on_step = function(self)
		if self.old_nodename ~= self.nodename then
			self.set_node(self,dtime)
		end
    end,
})

minetest.override_item("default:stick",{
	on_place = function(itemstack, placer, pointed_thing)
		minetest.add_entity(pointed_thing.above,"nano_blocks:block")
	end,
})


minetest.register_node("nano_blocks:base", {
	description = "NanoBlocks Base",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
		},
	},
	on_construct = function(pos)
		set_up_base(pos)
	end,
})


set_up_base = function(pos)
	pos.x = (pos.x - 0.5) + (0.5/nano_blocks.size)
	pos.z = (pos.z - 0.5) + (0.5/nano_blocks.size)
	pos.y = (pos.y - 0.5) + (0.5/nano_blocks.size)
	
	for x = 0,nano_blocks.size - 1 do
		for z = 0,nano_blocks.size - 1 do
			minetest.add_entity({x=pos.x+(x/nano_blocks.size),y = pos.y+(1/nano_blocks.size), z=pos.z+(z/nano_blocks.size)}, "nano_blocks:block")
		end
	end

end
