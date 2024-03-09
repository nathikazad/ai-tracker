import { getHasura } from "../config";

export async function getEventTypes() {
    const chain = getHasura();
    const resp = await chain.query({
        event_types_by_pk: [{
            name: "root"
        }, {
            children: [
                {}, {
                    name: true,
                    metadata: [{}, true],
                    children: [
                        {}, {
                            name: true,
                            metadata: [{}, true],
                            children: [
                                {}, {
                                    name: true,
                                    metadata: [{}, true],
                                }
                            ]
                        }
                    ]
                }
            ]
        }]
    })

    return cleanData(JSON.stringify(resp.event_types_by_pk));
    // console.log(str);
    // return JSON.stringify(str, null, 2);
    
    
}

type Node = {
    name: string;
    metadata?: string | null;
    children?: Node[];
};

function cleanData(input: string): Node[] {
    const data: { children: Node[] } = JSON.parse(input);

    function removeEmptyChildrenAndNullMetadata(node: Node): Node {
        const cleanedNode: Node = { ...node };

        if (cleanedNode.metadata === null) {
            delete cleanedNode.metadata;
        }

        if (cleanedNode.children) {
            cleanedNode.children = cleanedNode.children
                .filter(child => child.name !== undefined)
                .map(removeEmptyChildrenAndNullMetadata)
                .filter(child => child.children === undefined || child.children.length > 0);

            if (cleanedNode.children.length === 0) {
                delete cleanedNode.children;
            }
        }

        return cleanedNode;
    }

    return data.children.map(removeEmptyChildrenAndNullMetadata);
}

