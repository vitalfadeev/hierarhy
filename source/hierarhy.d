/**
Example:
--------------------
class MenuItem
{
    mixin Hierarhy!( typeof(this) );
}
--------------------
*/
mixin template Hierarhy( T )
{
    T parent;
    // childs
    T firstChild;
    T lastChild;
    // siblings
    T prevSibling;
    T nextSibling;


    import std.traits : isCallable;


    /** */
    T appendChild( T )( T child )
    {
        // Remove from parent
        if ( child.parent )
        {
            child.removeFromParent();
        }

        child.parent = this;

        // Add
        if ( firstChild is null )
        {
            firstChild = child;
            lastChild  = child;
        } 
        else // firstChild !is null
        {
            child.prevSibling     = lastChild;
            lastChild.nextSibling = child;
            lastChild             = child;
        }

        return child;
    }    


    /** */
    T addNextSibling( T b )
    {
        // Remove from parent
        if ( b.parent )
        {
            b.removeFromParent();
        }

        // Add
        auto ns = nextSibling;

        // exist next
        if ( ns )
        {
            ns.prevSibling = b;
            b.nextSibling  = ns;
            nextSibling    = b;
            b.prevSibling  = this;
            b.parent       = parent;
        }
        else // not exist next. we last
        {
            if ( parent )
            {
                parent.lastChild = b;
            }

            nextSibling   = b;
            b.prevSibling = this;
            b.parent      = parent;
        }

        return b;
    }


    /** */
    void removeFromParent()
    {
        assert( parent !is null );

        parent.removeChild( this );
    }


    /** */
    void removeChild( T c )
    {
        assert( c !is null );

        // Childs
        if ( firstChild == c )
        {
            firstChild = firstChild.nextSibling;
        }

        if ( lastChild == c )
        {
            lastChild = lastChild.prevSibling;
        }

        // Parent
        c.parent = null;

        // Siblings
        if ( c.prevSibling )
        {
            c.prevSibling.nextSibling = c.nextSibling;
        }

        if ( c.nextSibling )
        {
            c.nextSibling.prevSibling = c.prevSibling;
        }

        c.prevSibling = null;
        c.nextSibling = null;
    }


    void removeChilds()
    {
        if ( firstChild !is null )
        {
            for ( T scan = firstChild; scan !is null; scan = scan.nextSibling )
            {
                scan.parent = null;
                scan.prevSibling = null;
                scan.destroy();
            }

            firstChild = null;
            lastChild  = null;
        }
    }


    //enum HierarhySpanMode
    //{
    //    shallow,
    //    depth,
    //    breadth,
    //}


    //struct HeirarhyIterator
    //{
    //import std.typecons : RefCounted;
    //import std.typecons : RefCountedAutoInitialize;
    //private:
    //    RefCounted!( HeirarhyIteratorImpl, RefCountedAutoInitialize.no ) impl = void;
    //    this( T root, HierarhySpanMode mode = HierarhySpanMode.shallow ) @trusted
    //    {
    //        impl = typeof( impl )( root, mode );
    //    }
    //public:
    //    // ForwardRange
    //    @property bool empty()    { return impl.empty; }
    //    @property T    front()    { return impl.front; }
    //    void           popFront() { impl.popFront(); }
    //}


    //struct HeirarhyIteratorImpl
    //{
    //    T _cur;

    //    this( T root, HierarhySpanMode mode )
    //    {
    //        _cur = root;
    //    }

    //    @property bool empty()
    //    {
    //        return ( _cur is null );
    //    }

    //    @property T front()
    //    {
    //        return _cur;
    //    }

    //    void popFront()
    //    {
    //        _cur = _cur.nextSibling;
    //    }
    //}


    //auto iterator()
    //{
    //    return HeirarhyIterator( this );
    //}


    //auto iteratorlevel1()
    //{
    //    return HeirarhyIterator( this, HierarhySpanMode.shallow );
    //}


    /** */
    @property 
    size_t length()
    {
        size_t l = 1;

        for( T scan = nextSibling; scan !is null; scan = scan.nextSibling )
        {
            l += 1;
        }

        return l;
    }


    /** */
    @property 
    size_t childsCount()
    {
        size_t cnt = 0;

        if ( firstChild !is null )
        {        
            for( T scan = firstChild; scan !is lastChild; scan = scan.nextSibling )
            {
                cnt += 1;
            }
        }

        return cnt;
    }


    T opIndex( size_t i )
    {
        // 0
        if ( i == 0 )
        {
            return this;
        }

        // 1 .. $
        T scan = nextSibling;
        size_t l = i - 1;
        
        do
        {
            if ( scan is null )
            {
                // range
                throw new Exception( "Range" );
                //return null;
            }

            if ( l == 0 )
            {
                // OK. found
                return scan;                
            }

            scan = scan.nextSibling;
            l -= 1;
        } while ( 1 );
    }


    /** */
    void each( alias IteratorFactory = inDepthIterator, FUNC )( FUNC func )
    {
        foreach( a; IteratorFactory() )
        {
            func( a );
        }
    }


    /** */
    void eachChild( alias IteratorFactory = inDepthChildIterator, FUNC )( FUNC func )
    {
        foreach( a; IteratorFactory() )
        {
            func( a );
        }
    }


    /** */
    void eachParent( alias IteratorFactory = parentIterator, FUNC )( FUNC func )
    {
        foreach( a; IteratorFactory() )
        {
            func( a );
        }
    }


    /** */
    T findDeepest( FUNC )( FUNC func )
      if ( isCallable!FUNC )
    {
        if ( firstChild !is null )
        {
            for ( auto a = firstChild, end = lastChild.nextSibling; a !is end; a = a.nextSibling )
            {
                // Found
                if ( func( a ) )
                {
                    // Test his childs. Recursive
                    auto c = a.findDeepest( func );

                    if ( c is null )
                        return a;
                    else
                        return c;
                }
            }
        }

        return null;
    }


    /** */
    T findFirst( alias IteratorFactory = inDepthIterator, FUNC )( FUNC func )
      if ( isCallable!FUNC )
    {
        foreach ( a; IteratorFactory() )
        {
            if ( func( a ) )
            {
                return a;
            }
        }

        return null;
    }


    /** */
    T findFirst( alias IteratorFactory = inDepthIterator, T )( T needle )
      if ( !isCallable!T )
    {
        foreach( a; IteratorFactory() )
        {
            if ( a == needle )
            {
                return a;
            }
        }

        return null;
    }


    /** */
    auto inDepthIterator()
    {
        return InDepthIterator( this );
    }


    /** */
    auto inDepthChildIterator()
    {
        return InDepthIterator( this.firstChild );
    }


    /** */
    auto parentIterator()
    {
        return ParentIterator( this.parent );
    }


    /** */
    auto plainChildIterator()
    {
        return PlainIterator( this.firstChild );
    }


    /** */
    struct InDepthIterator
    {
        T cur;
        T[] stack;

    public:
        // ForwardRange
        @property bool empty()    { return cur is null; }
        @property T    front()    { return cur; }

        void popFront()
        {
            import std.range.primitives : back;
            import std.range.primitives : popBack;

            // in depth
            if ( cur.firstChild !is null )
            {
                stack ~= cur;
                cur = cur.firstChild;
            }
            else // in width
            {
                cur = cur.nextSibling;         // RIGHT

            l1:
                if ( cur is null )
                {
                    if ( stack.length != 0 )
                    {
                        cur = stack.back;      // UP
                        stack.popBack();       // 
                        cur = cur.nextSibling; // RIGHT
                        goto l1;
                    }
                    else
                    {
                        return;                // FINISH
                    }
                }
            }
        }

    }


    /** */
    struct PlainIterator
    {
        T cur;

    public:
        // ForwardRange
        @property bool empty()    { return cur is null; }
        @property T    front()    { return cur; }

        void popFront()
        {
            cur = cur.nextSibling;         // RIGHT
        }

    }


    /** */
    struct ParentIterator
    {
        T cur;

    public:
        // ForwardRange
        @property bool empty()    { return cur is null; }
        @property T    front()    { return cur; }

        void popFront()
        {
            cur = cur.parent;              // UP
        }

    }


    /** */
    T findParent( FUNC )( FUNC func )
    {
        auto scan = this.parent;

        while ( scan !is null )
        {
            if ( func( scan ) )
            {
                return scan;
            }

            scan = scan.parent;
        }

        return null;
    }


    /** */
    T root()
    {
        auto scan = this.parent;

        while ( scan !is null )
        {
            if ( scan.parent is null )
            {
                return scan;
            }

            scan = scan.parent;
        }

        return null;
    }


    /** */
    CLS findParentClass( CLS )()
    {
        import ui.tools : instanceof;
        return cast( CLS ) findParent( ( T a ) => ( a.instanceof!CLS ) );
    }
}


///
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

