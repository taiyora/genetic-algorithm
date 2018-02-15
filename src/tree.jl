"""
A TreeNode represents a single element of an evaluable expression.
It can represent either a value, or an operation such as addition.

For example, a node with the '+' operator and three children with the values 1, 5, and 10
will return the value 16 when evaluated.

Of course, any child may also be an operator; in this way, complex expressions can be built.
Values are of type Float64, and randomly generated values are between 0.0 and 1.0
"""
module TreeNode
	"A node can function as either a value, or an operator on its children (e.g. `+`)."
	Function = Union{Float64, Char}

	operators = ['+', '-', '*']

	type Node
		valOp::Function # The value or operator that the node functionally represents
		children::Vector{Node}
	end

	Node()                = Node(0.0,   Vector{Node}())
	Node(valOp::Function) = Node(valOp, Vector{Node}())

	function generateRandom()::Node
		if rand(Bool)
			# Generate a Value node
			value = rand()
			return Node(value)

		else
			# Generate an Operator node
			index = rand(1:length(operators))
			return Node(operators[index])
		end
	end

	function setValue(node::Node, value::Float64)
		@assert isLeaf(node) # Only a leaf can be a value; a parent must be an operator
		node.valOp = value
	end

	function setOperator(node::Node, operator::Char)
		@assert operator in operators
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
	function printAsExpr(node::TreeNode.Node)
		if typeof(node.valOp) == Float64
			print(' ', node.valOp)
		
		else
			print(" (", node.valOp)

			for child in node.children
				printAsExpr(child)
			end

			print(')')
		end
	end

	"Returns the number of nodes in a given tree."
	function getSize(node::TreeNode.Node)::Int
		size = 1

		for child in node.children
			size += getSize(child)
		end

		return size
	end

	"Returns a tree as a list of its nodes."
	function toVector(node::TreeNode.Node)::Vector{TreeNode.Node}
		nodes = [node]

		for child in node.children
			nodes = vcat(nodes, toVector(child))
		end

		return nodes
	end

	"Returns a random node from a given tree."
	function getRandomNode(node::TreeNode.Node)::TreeNode.Node
		nodeVector = toVector(node)
		nNodes = length(nodeVector)

		index = rand(1:nNodes)
		return nodeVector[index]
	end

	"Generates a completely random tree with the given number of nodes."
	function generateRandom(nNodes::Int)::TreeNode.Node
		root = TreeNode.generateRandom()

		# Continously find random nodes to make into parents
		for i in 2:nNodes # Start at 2, since we begin with a root node
			target = getRandomNode(root)

			if typeof(target.valOp) == Float64
				index = rand(1:length(TreeNode.operators))
				TreeNode.setOperator(target, TreeNode.operators[index])
			end

			TreeNode.addChild(target, TreeNode.generateRandom())
		end

		return fix(root)
	end

	"Finds Operator nodes with no children and turns them into Value nodes."
	function fix(node::TreeNode.Node)::TreeNode.Node
		if length(node.children) == 0 && typeof(node.valOp) == Char
			node.valOp = rand()
		
		else
			for child in node.children
				child = fix(child)
			end
		end

		return node
	end

	"Evaluates a tree as an expression, resulting in a single output."
	function evaluate(node::TreeNode.Node)::Float64
		if typeof(node.valOp) == Char
			if node.valOp == '+'
				return reduce(+, map(evaluate, node.children))

			elseif node.valOp == '-'
				return reduce(-, map(evaluate, node.children))

			else # multiplication
				return reduce(*, map(evaluate, node.children))
			end

		else
			return node.valOp
		end
	end
end
