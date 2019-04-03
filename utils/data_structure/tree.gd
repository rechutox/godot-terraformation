extends Reference
class_name DataStructure_Tree

class TreeNode:
    var is_root: bool = false
    var data: Object = null
    var children: Array = []

    func add_child(data: Object):
        var tn = TreeNode.new()
        tn.data = data
        children.append(tn)

