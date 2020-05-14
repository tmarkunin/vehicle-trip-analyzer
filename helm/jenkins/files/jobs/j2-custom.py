import base64

def extra_filters():
    """ Declare some custom filters.

        Returns: dict(name = function)
    """
    return dict(
        b64encode = lambda n: base64.b64encode(n.encode("utf-8")).decode('utf-8'),
    )
