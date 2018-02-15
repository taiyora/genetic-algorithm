"""
A TreeNode represents a single element of an evaluable expression.
It can represent either a value, or an operation such as addition.

For example, a node with the '+' operator and three children with the values 1, 5, and 10
will return the value 16 when evaluated.

Of course, any child may also be an operator; in this way, complex expressions can be built.
"""
module TreeNode
	"A node can function as either a value, or an operator on its children (e.g. `+`)."
	Function = Union{Int, Char}

	type Node
		valOp::Function # The value or operator that the node functionally represents
		children::Vector{Node}
	end

	Node()                = Node(0,     Vector{Node}())
	Node(valOp::Function) = Node(valOp, Vector{Node}())

	function setValue(node::Node, value::Int)
		@assert isLeaf(node) # Only a leaf can be a value; a parent must be an operator
		node.valOp = value
	end

	function setOperator(node::Node, operator::Char)
		@assert operator in ['+', '-', '*']
		node.valOp = operator
	end

	function addChild(parent::Node, child::Node)
		@assert isOperator(parent) # A node must be an operator before it can accept children
		push!(parent.children, child)
	end

	function isLeaf(node::Node)::Bool
		return length(node.children) == 0
	end

	function isOperator(node::Node)::Bool
		return typeof(node.valOp) == Char
	end
end

"""
The Tree module contains methods dealing with Trees as a whole.
This includes printing, generation, and evaluation.
"""
module Tree
	using TreeNode

	"Given a root node (or any node in fact), will print the tree as a nested expression."
	function printTree(node::TreeNode.Node)
		if typeof(node.valOp) == Int
			print(node.valOp, ' ')
		
		else
			print('(', node.valOp, ' ')

			for child in node.children
				printTree(child)
			end

			print(')')
		end
	end
end
