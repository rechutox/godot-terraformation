# Terraformation

Visual node-based heightmap generator. Uses the GPU to create different kind of noise and apply effects to heightmaps.
Has a 3D view that updates in realtime.

Made with Godot Engine. Use the latest unofficial builds to run the project.

## Why?

Because I can 😜. I can't afford other alternatives like World Machine, the free tier
it's not good enough in any of the others, they are overcomplicated, slow,...
So I took the project to challenge myself and return something to the open-source community.

## TODO

For now, more nodes to further process the heightmap and the output node to export the heightmap...
It's a little usseless now, sorry. I'll be right back 😂.

Loading and saving projects.

Other terrain-processing nodes like thermal/hidraulic erosion, biome generation, watermaps, splatmaps...
trying to keep most of the heavy-lifting in the GPU to keep the program super-fast.

More options to customize the 3D view like water, terrain shader textures, light direction, daytime, fog,...
I don't intend to use it to make full renders since there are way better tools for that but we'll see.

A better terrain shader, mine works but it's a little rough... And a sky shader too... and water shader...
I need help 🤣.

A node graph editor that will allow the user to make his own nodes.
The user will create the shader, add some properties and slots, then save the node and
activate it via a manager, the node it will appear in the appropiate menu depending of the
type of node created (filter, input or output).

Waaaay in the future: A terrain sculpting mode that will work on top of the resulting heightmap,
so we can export a mesh with options to tile it, generate LODs,...
