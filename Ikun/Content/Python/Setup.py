import unreal as ue

ue.log('load python file')

@ue.uclass()
class PyFnLib(ue.BlueprintFunctionLibrary):
    @ue.ufunction(static = True, meta = dict(Category = "Python Blueprint"))
    def PyFn():
        ue.SystemLibrary.print_string(None, f'执行方法成功', text_color = [255, 255, 255, 255])

    @ue.ufunction(static = True, meta = dict(Category = "Python Blueprint"), ret = ue.Array(ue.Vector), params = [str])
    def PyTest(aaa):
        ue.SystemLibrary.print_string(None, f'执行方法成功 {aaa}', text_color = [255, 255, 255, 255])

        vec = []
        vec.append(ue.Vector(10, 20, 30))
        vec.append(ue.Vector(40, 50, 60))
        return vec