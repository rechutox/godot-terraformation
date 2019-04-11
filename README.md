# Terraformation

![Screenshot of Terraformation in action](https://i.imgur.com/bfa3DRG.jpg)

Node-based heightmap generator and composer. Uses the GPU to create different kinds of noise and apply effects on heightmaps.
Has a 3D view that updates in real time.

At the end you can use an export node to save the texture to a PNG file.

Made with Godot Engine. Use the latest unofficial builds to run the project.

## Why?

Because I can 😜. I can't afford other alternatives like World Machine, their free tier
it's not good enough, they are overcomplicated, slow,...
So I took the project to challenge myself and return something to the open-source community.

Much later: Never mind, I found Gaea, pretty much the same I'm trying to do 🙃 But still slow and buggy.

## TODO

For now, more nodes to further process the heightmap.

Other terrain-processing nodes like thermal/hydraulic erosion, biome generation, watermaps, splatmaps...
trying to put most of the heavy-lifting in the GPU to keep the application super-fast.

More options to customize the 3D view like water, terrain shader textures, light direction, daytime, fog,...
I don't intend to use it to make full renders since there are way better tools for that but we'll see.

A better terrain shader, mine works but it's a little rough... And a sky shader too... and water shader...
I need help 🤣.

Still unsure but: A node graph editor that will allow the user to make his own nodes.
The user will create the shader, add some properties and slots, then save the node and
activate it via a manager, the node will appear in the appropiate menu depending of its
type (filter, input or output).

Waaaay in the future: A terrain sculpting mode that will work on top of the resulting heightmap,
so we can export a mesh with options to tile it, generate LODs,... Something like the terrain editor
of Roblox... I don't used it much but I love it.
