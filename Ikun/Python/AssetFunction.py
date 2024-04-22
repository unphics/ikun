import unreal

# 修改脚本后可以reload: 写入import importlib   importlib.reload(AssetFunction)
# 导入资源的任务
def _build_import_task(filename, dst_path, options = None):
    task = unreal.AssetImportTask()
    task.set_editor_property('automated', True)
    task.set_editor_property('destination_name', '')
    task.set_editor_property('destination_path', dst_path)
    task.set_editor_property('filename', filename)
    task.set_editor_property('replace_existing', True)
    task.set_editor_property('save', True)
    task.set_editor_property('options', options)
    return task

def _exec_import_task(tasks):
    unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
    for task in tasks:
        for path in task.get_editor_property('imported_object_paths'):
            print('Imported: %s'%path)


def _import_simple_assets():
    # 不可以使用相对路径, 相对路径的起点在引擎目录下/Binary/Win64
    texture_tga = 'D:/CppProj/ikun/Ikun/Python/Texture.TGA'
    sound_wav = 'D:/CppProj/ikun/Ikun/Python/Sound.WAV'

    texture_task = _build_import_task(texture_tga, '/Game/Ikun/Import')
    sound_task = _build_import_task(sound_wav, '/Game/Ikun/Import')
    _exec_import_task([texture_task, sound_task])

def _import_mesh_asset():
    static_mesh = 'D:/CppProj/ikun/Ikun/Python/StaticMesh.FBX'
    skeletal_mesh = 'D:/CppProj/ikun/Ikun/Python/SkeletalMesh.FBX'

    static_task = _build_import_task(static_mesh, '/Game/Ikun/Import', _build_static_mesh_import_options())
    skeletal_task = _build_import_task(skeletal_mesh, '/Game/Ikun/Import', _build_skeletal_mesh_import_options())
    _exec_import_task([static_task, skeletal_task])

# import AssetFunction as af af.import_asset()
def import_asset():
    # _import_simple_assets()
    _import_mesh_asset()

def _build_static_mesh_import_options():
    options = unreal.FbxImportUI()

    options.set_editor_property('import_mesh', True)
    options.set_editor_property('import_textures', False)
    options.set_editor_property('import_materials', True)
    options.set_editor_property('import_as_skeletal', False)

    options.static_mesh_import_data.set_editor_property('import_translation', unreal.Vector(50.0, 0.0, 0.0))
    options.static_mesh_import_data.set_editor_property('import_rotation', unreal.Rotator(50.0, 0.0, 0.0))
    options.static_mesh_import_data.set_editor_property('import_uniform_scale', 1.0)

    options.static_mesh_import_data.set_editor_property('combine_meshes', True)
    options.static_mesh_import_data.set_editor_property('generate_lightmap_u_vs', True)
    options.static_mesh_import_data.set_editor_property('auto_generate_collision', True)

def _build_skeletal_mesh_import_options():
    options = unreal.FbxImportUI()

    options.set_editor_property('import_mesh', True)
    options.set_editor_property('import_textures', False)
    options.set_editor_property('import_materials', True)
    options.set_editor_property('import_as_skeletal', True)

    options.skeletal_mesh_import_data.set_editor_property('import_translation', unreal.Vector(50.0, 0.0, 0.0))
    options.skeletal_mesh_import_data.set_editor_property('import_rotation', unreal.Rotator(50.0, 0.0, 0.0))
    options.skeletal_mesh_import_data.set_editor_property('import_uniform_scale', 1.0)

    options.skeletal_mesh_import_data.set_editor_property('import_morph_targets', True)
    options.skeletal_mesh_import_data.set_editor_property('update_skeleton_reference_pose', False)