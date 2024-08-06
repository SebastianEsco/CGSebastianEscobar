bl_info = {
 "name": "Import Path From Unity",
 "blender": (4,0,0),
 "category": "Add"
}

import bpy
import json


class ImportPath(bpy.types.Operator):
    bl_idname = "add.import_path"
    bl_label = "Import Path"
    bl_options = {'REGISTER'}
    
    def execute(self, context):
        clipboard = context.window_manager.clipboard
        text = clipboard.encode('utf8')
        try:
            data_json = json.loads(text)
            vertices = []
            edges = []
            
            if "UNITY" in data_json.keys():
                for index, vec in enumerate(data_json["UNITY"]):
                    vertices.append((vec["x"], vec["z"], vec["y"]))
                    if index > 0:
                        edges.append((index - 1, index))
        except Exception as e:
            return {'CANCELLED'}
                    
        new_mesh =  bpy.data.meshes.new("new_path")
        new_mesh.from_pydata(vertices,edges,[])
        new_object = bpy.data.objects.new("new_path_object", new_mesh)
        context.collection.objects.link(new_object)
        
        bpy.ops.object.select_all(action='DESELECT')
        bpy.data.objects[new_object.name].select_set(state = True, view_layer = bpy.context.view_layer)
        bpy.context.view_layer.objects.active = new_object
        bpy.ops.object.convert(target='CURVE')
                
        print(text)
        return {'FINISHED'}
    
    def menu_func(self, context):
        self.layout.operator(ImportPath.bl_idname)   

def register():
    bpy.utils.register_class(ImportPath)
    bpy.types.VIEW3D_MT_add.append(ImportPath.menu_func)

def unregister():
    bpy.utils.unregister_class(ImportPath)

if __name__ == '__main__':
       register()