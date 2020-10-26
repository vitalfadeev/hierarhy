mixin template Hierarhy( T )
  @property size_t length()
  T    root()
  T    appendChild( T )( T child )
  T    addNextSibling( T b )
  void removeFromParent()
  void removeChild( T c )
  void removeChilds()
  void each( alias IteratorFactory = inDepthIterator, FUNC )( FUNC func )
  void eachChild( alias IteratorFactory = inDepthChildIterator, FUNC )( FUNC func )
  void eachParent( alias IteratorFactory = parentIterator, FUNC )( FUNC func )
  T    findFirst( alias IteratorFactory = inDepthIterator, FUNC )( FUNC func )
  T    findFirst( alias IteratorFactory = inDepthIterator, T )( T needle )
  T    findParent( FUNC )( FUNC func )
  CLS  findParentClass( CLS )()
  T    opIndex( size_t i )
  auto inDepthIterator()
  auto inDepthChildIterator()
  auto parentIterator()
  auto plainChildIterator()
  struct InDepthIterator
  struct PlainIterator
  

// Example
unittest
{
    class Node
    {
        mixin Hierarhy!( typeof(this) );
    }

    //
    auto root  = new Node;
    auto child = new Node;
    auto outsider = new Node;

    root.appendChild( child );

    // 
    uint counter;
    root.each( ( Node a ) => ( counter += 1 ) );
    assert( counter == 2 );

    // 
    uint childCounter;
    root.eachChild( ( Node a ) => ( childCounter += 1 ) );
    assert( childCounter == 1 );

    // 
    auto found = root.findFirst( ( Node a ) => ( a == child ) );
    assert( found !is null );

    // 
    found = root.findFirst( ( Node a ) => ( a == outsider ) );
    assert( found is null );

    // 
    assert( root.findFirst( child ) !is null );
    assert( root.findFirst( outsider ) is null );

    //
    auto a = new Node;
    auto b = new Node;
    auto c = new Node;
    auto d = new Node;
    auto e = new Node;

    //     a
    //   / | \
    //  b  c   d
    //  |
    //  e
    a.appendChild( b );
    a.appendChild( c );
    a.appendChild( d );
    b.appendChild( e );

    //
    assert( a.findFirst( a ) == a );
    assert( a.findFirst( b ) == b );
    assert( a.findFirst( c ) == c );
    assert( a.findFirst( d ) == d );
    assert( a.findFirst( e ) == e );
    assert( a.findFirst( ( Node node ) => ( node == e ) ) == e );
    assert( a.findFirst( ( Node node ) => ( node == d ) ) == d );
    assert( a.findFirst( ( Node node ) => ( node == outsider ) ) is null );

    //
    Node[] nodes;
    a.each( ( Node node ) => ( nodes ~= node ) );
    assert( nodes == [ a, b, e, c, d ] );

    //
    Node[] childNode;
    a.eachChild( ( Node node ) => ( childNode ~= node ) );
    assert( childNode == [ b, e, c, d ] );

    //
    Node[] plainChildNode;
    a.eachChild!( a.plainChildIterator )( ( Node node ) => ( plainChildNode ~= node ) );
    assert( plainChildNode == [ b, c, d ] );

    //
    Node[] parentNodes;
    a.eachParent( ( Node node ) => ( parentNodes ~= node ) );
    assert( parentNodes.length == 0 );

    e.eachParent( ( Node node ) => ( parentNodes ~= node ) );
    assert( parentNodes == [ b, a ] );
}