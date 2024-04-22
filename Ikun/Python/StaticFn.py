import unreal

def watch_func_lib():
    for x in sorted(dir(unreal.IkunFuncLib)):
        print(x)

def log_error():
    unreal.IkunFuncLib.called_from_python("6666666")

def _get_gradient_color(x):
    return (x / 512.0, 1 - x / 512.0, 0, 1)

# import StaticFn as sf
# sf.gen_colored_dir()
def gen_colored_dir():
    for x in range(100, 400):
        dir_path = 'Game/Ikun/Python/' + str(x)
        linear_color = _get_gradient_color(x)
        unreal.IkunFuncLib.set_floder_color(dir_path, linear_color)
        unreal.EditorAssetLibrary.make_directory(dir_path)