-- NPCMeshData (ModuleScript in ReplicatedStorage)
-- Written by tools/blender/npcs.py: the shopkeeper characters. File > Import 3D of
-- assets/models/NPCMeshes.fbx + the installer put the meshes in ReplicatedStorage > NPCModels
-- (<Name> and <Name>Glow). Size = each mesh's size; Center = where its center sits, in studs,
-- from the point the character stands on (it faces -Z).
return {
	ShopRobot = {Size = Vector3.new(4.629, 8.100, 4.583), Center = Vector3.new(-0.175, 4.250, -0.742), GlowSize = Vector3.new(3.380, 9.090, 2.650), GlowCenter = Vector3.new(-0.000, 3.945, -0.045), GlowColor = Color3.fromRGB(90, 235, 255)},
	ArtDealer = {Size = Vector3.new(4.135, 9.527, 3.720), Center = Vector3.new(0.103, 4.764, -0.140), GlowSize = Vector3.new(2.040, 4.650, 1.650), GlowCenter = Vector3.new(-0.000, 7.195, -0.505), GlowColor = Color3.fromRGB(255, 210, 90)},
}
