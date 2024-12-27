# 1-c-c-sub

A boolean expression transformation function that removes constraints in a non-root AND node that are dominated 
by a negated form literal in found in a guard set of a terminal AND node.

### The implementation

The main function oneCcSub calls the function checking for a terminal AND at the current level of child-parent structure since the way 1ccSUb is applied is that a  terminal AND should be a sibling of the same parent to have an influence on the POA. Once the terminal AND node is found to exist say on the first level, it goes through all nested structure to find the POA and make the update because of that descendant rule. That is what the updatePoa does. It receives the common element (to be reducted from the POA) from the function checking for an AND terminal , checkForTerminalAnd.

If there is no terminal AND in the current children list (because it is in branch growing out on its own), just apply the oneccSub function to the children who have other children, ignoring anything else in the expression like symbols, and terminal nodes, because they, those with children (made use of getChildren), too can contain a terminal AND and be eligible for the transformation.